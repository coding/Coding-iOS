//
//  amrFileCodec.cpp
//  amrDemoForiOS
//
//  Created by Tang Xiaoping on 9/27/11.
//  Copyright 2011 test. All rights reserved.
//

#include "amrFileCodec.h"

typedef unsigned long long u64;
typedef long long s64;
typedef unsigned int u32;
typedef unsigned short u16;
typedef unsigned char u8;
int amrEncodeMode[] = {4750, 5150, 5900, 6700, 7400, 7950, 10200, 12200}; // amr 编码方式

u16 readUInt16(char* bis) {
    u16 result = 0;
    result += ((u16)(bis[0])) << 8;
    result += (u8)(bis[1]);
    return result;
}

u32 readUint32(char* bis) {
    u32 result = 0;
    result += ((u32) readUInt16(bis)) << 16;
    bis+=2;
    result += readUInt16(bis);
    return result;
}

s64 readSint64(char* bis) {
    s64 result = 0;
    result += ((u64) readUint32(bis)) << 32;
    bis+=4;
    result += readUint32(bis);
    return result;
}

NSData * fuckAndroid3GP(NSData *data) {
    //http://android.amberfog.com/?p=181
    u32 size = 0; 
    u32 type =0;
    u32 boxSize =0;
    //char HEADER_TYPE[] = {'f', 't', 'y', 'p'};
    
    char AMR_MAGIC_HEADER[6] = {0x23, 0x21, 0x41, 0x4d, 0x52, 0x0a};
    
    u32 brand =0;
    u32 minorVersion=0;
    //u32 *compatibleBrands;
    
    if (data.length<50) {
        NSLog(@"not android 3gp");
        return data;
    }
    char *bis = (char *)[data bytes];
    
    size = readUint32(bis);
    boxSize += 4;
    bis+=4;
    type = readUint32(bis);
    boxSize += 4;
    bis+=4;
    if (type!=0x66747970) {
        NSLog(@"not android 3gp");
        return data;
    }
    
    brand = readUint32(bis);
    boxSize += 4;
    bis+=4;
    minorVersion = readUint32(bis);
    boxSize += 4;
    bis+=4;
    int remainSize = (int)(size - boxSize);
    if (remainSize > 0) {
        //compatibleBrands = new u32[remainSize / 4];
        for (int i = 0; i < remainSize / 4; i++) {
            //compatibleBrands[i] = 
            readUint32(bis);
            bis+=4;
        }
    }
    
    boxSize = 0;
    size = readUint32(bis);
    boxSize += 4;
    bis+=4;
    type = readUint32(bis);
    boxSize += 4;
    bis+=4;
    
    int rawAmrDataLength=(size - boxSize);
    int fullAmrDataLength = 6 + rawAmrDataLength;
    //char* amrData = new char[fullAmrDataLength];
    NSMutableData *amrData = [[NSMutableData alloc]initWithCapacity:fullAmrDataLength];
    //memcpy(amrData,AMR_MAGIC_HEADER,6);
    //memcpy(amrData+6,bis,rawAmrDataLength);
    [amrData appendBytes:AMR_MAGIC_HEADER length:6];
    [amrData appendBytes:bis length:rawAmrDataLength];
    
    return amrData;    
}


#pragma mark - Decode
//decode

const int myround(const double x)
{
	return((int)(x+0.5));
} 

// 根据帧头计算当前帧大小
int caclAMRFrameSize(unsigned char frameHeader)
{
	int mode;
	int temp1 = 0;
	int temp2 = 0;
	int frameSize;
	
	temp1 = frameHeader;
	
	// 编码方式编号 = 帧头的3-6位
	temp1 &= 0x78; // 0111-1000
	temp1 >>= 3;
	
	mode = amrEncodeMode[temp1];
	
	// 计算amr音频数据帧大小
	// 原理: amr 一帧对应20ms，那么一秒有50帧的音频数据
	temp2 = myround((double)(((double)mode / (double)AMR_FRAME_COUNT_PER_SECOND) / (double)8));
	
	frameSize = myround((double)temp2 + 0.5);
	return frameSize;
}

// 读第一个帧 - (参考帧)
// 返回值: 0-出错; 1-正确
int ReadAMRFrameFirstData(char* fpamr,int pos, NSInteger maxLen, unsigned char frameBuffer[], int* stdFrameSize, unsigned char* stdFrameHeader)
{
    int nPos = 0;
	memset(frameBuffer, 0, sizeof(char *));
	
	// 先读帧头
	//fread(stdFrameHeader, 1, sizeof(unsigned char), fpamr);
    stdFrameHeader[0] = fpamr[pos];nPos++;
    if (pos+nPos >= maxLen) {
        return 0;
    }
	//if (feof(fpamr)) return 0;
	
	// 根据帧头计算帧大小
	*stdFrameSize = caclAMRFrameSize(*stdFrameHeader);
	
	// 读首帧
	frameBuffer[0] = *stdFrameHeader;
    if ((*stdFrameSize-1)*sizeof(unsigned char)<=0) {
        return 0;
    }
    
    memcpy(&(frameBuffer[1]), fpamr+pos+nPos, (*stdFrameSize-1)*sizeof(unsigned char));
	//fread(&(frameBuffer[1]), 1, (*stdFrameSize-1)*sizeof(unsigned char), fpamr);
	//if (feof(fpamr)) return 0;
    nPos += (*stdFrameSize-1)*sizeof(unsigned char);
    if (pos+nPos >= maxLen) {
        return 0;
    }
	
	return nPos;
}

// 返回值: 0-出错; 1-正确
int ReadAMRFrameData(char* fpamr,int pos,NSInteger maxLen, unsigned char frameBuffer[], int stdFrameSize, unsigned char stdFrameHeader)
{
    int nPos = 0;
	unsigned char frameHeader; // 帧头
	
	memset(frameBuffer, 0, sizeof(char *));
	
	// 读帧头
	// 如果是坏帧(不是标准帧头)，则继续读下一个字节，直到读到标准帧头
	while(1)
        {
		//bytes = fread(&frameHeader, 1, sizeof(unsigned char), fpamr);
		//if (feof(fpamr)) return 0;
        if (pos+nPos >=maxLen) {
            return 0;
        }
        frameHeader = fpamr[pos+nPos]; nPos++;
		if (frameHeader == stdFrameHeader) break;
        }
	
	// 读该帧的语音数据(帧头已经读过)
	frameBuffer[0] = frameHeader;
	//bytes = fread(&(frameBuffer[1]), 1, (stdFrameSize-1)*sizeof(unsigned char), fpamr);
	//if (feof(fpamr)) return 0;
    if ((stdFrameSize-1)*sizeof(unsigned char)<=0) {
        return 0;
    }
	memcpy(&(frameBuffer[1]), fpamr+pos+nPos, (stdFrameSize-1)*sizeof(unsigned char));
    nPos += (stdFrameSize-1)*sizeof(unsigned char);
    if (pos+nPos >= maxLen) {
        return 0;
    }
    
	return nPos;
}

void WriteWAVEHeader(NSMutableData* fpwave, int nFrame)
{
	char tag[10] = "";
	
	// 1. 写RIFF头
	RIFFHEADER riff;
	strcpy(tag, "RIFF");
	memcpy(riff.chRiffID, tag, 4);
	riff.nRiffSize = 4                                     // WAVE
	+ sizeof(XCHUNKHEADER)               // fmt 
	+ sizeof(WAVEFORMATX)           // WAVEFORMATX
	+ sizeof(XCHUNKHEADER)               // DATA
	+ nFrame*160*sizeof(short);    // 
	strcpy(tag, "WAVE");
	memcpy(riff.chRiffFormat, tag, 4);
	//fwrite(&riff, 1, sizeof(RIFFHEADER), fpwave);
    [fpwave appendBytes:&riff length:sizeof(RIFFHEADER)];
	
	// 2. 写FMT块
	XCHUNKHEADER chunk;
	WAVEFORMATX wfx;
	strcpy(tag, "fmt ");
	memcpy(chunk.chChunkID, tag, 4);
	chunk.nChunkSize = sizeof(WAVEFORMATX);
	//fwrite(&chunk, 1, sizeof(XCHUNKHEADER), fpwave);
    [fpwave appendBytes:&chunk length:sizeof(XCHUNKHEADER)];
	memset(&wfx, 0, sizeof(WAVEFORMATX));
	wfx.nFormatTag = 1;
	wfx.nChannels = 1; // 单声道
	wfx.nSamplesPerSec = 8000; // 8khz
	wfx.nAvgBytesPerSec = 16000;
	wfx.nBlockAlign = 2;
	wfx.nBitsPerSample = 16; // 16位
    //fwrite(&wfx, 1, sizeof(WAVEFORMATX), fpwave);
    [fpwave appendBytes:&wfx length:sizeof(WAVEFORMATX)];
	
	// 3. 写data块头
	strcpy(tag, "data");
	memcpy(chunk.chChunkID, tag, 4);
	chunk.nChunkSize = nFrame*160*sizeof(short);
	//fwrite(&chunk, 1, sizeof(XCHUNKHEADER), fpwave);
    [fpwave appendBytes:&chunk length:sizeof(XCHUNKHEADER)];

}

NSData* DecodeAMRToWAVE(NSData* data) {
	NSMutableData* fpwave = nil;
	void * destate;
	int nFrameCount = 0;
	int stdFrameSize;
    int nTemp;
    char bErr = 0;
	unsigned char stdFrameHeader;
	
	unsigned char amrFrame[MAX_AMR_FRAME_SIZE];
	short pcmFrame[PCM_FRAME_SIZE];
	
	if (data.length<=0) {
        return nil;
    }
    
	char *rfile = (char *)[data bytes];
    NSInteger maxLen = [data length];
    int pos = 0;
    
    //有可能是android 3gp格式
    if (strncmp(rfile, AMR_MAGIC_NUMBER, strlen(AMR_MAGIC_NUMBER)))
        {
		data = fuckAndroid3GP(data);
        }
    
    rfile = (char *)[data bytes];
	// 检查amr文件头
    if (strncmp(rfile, AMR_MAGIC_NUMBER, strlen(AMR_MAGIC_NUMBER)))
    {
    return nil;
    }
    
	pos += strlen(AMR_MAGIC_NUMBER);
	// 创建并初始化WAVE文件
	
	fpwave = [[NSMutableData alloc]init];
	//WriteWAVEHeader(fpwave, nFrameCount);
	
	/* init decoder */
	destate = Decoder_Interface_init();
	
	// 读第一帧 - 作为参考帧
	memset(amrFrame, 0, sizeof(amrFrame));
	memset(pcmFrame, 0, sizeof(pcmFrame));
	//ReadAMRFrameFirst(fpamr, amrFrame, &stdFrameSize, &stdFrameHeader);
    
    nTemp = ReadAMRFrameFirstData(rfile,pos,maxLen, amrFrame, &stdFrameSize, &stdFrameHeader);
    if (nTemp==0) {
        Decoder_Interface_exit(destate);
        return data;
    }
    pos += nTemp;
	
	// 解码一个AMR音频帧成PCM数据
	Decoder_Interface_Decode(destate, amrFrame, pcmFrame, 0);
	nFrameCount++;
	//fwrite(pcmFrame, sizeof(short), PCM_FRAME_SIZE, fpwave);
    [fpwave appendBytes:pcmFrame length:PCM_FRAME_SIZE*sizeof(short)];

	
	// 逐帧解码AMR并写到WAVE文件里
	while(1)
        {
		memset(amrFrame, 0, sizeof(amrFrame));
		memset(pcmFrame, 0, sizeof(pcmFrame));
		//if (!ReadAMRFrame(fpamr, amrFrame, stdFrameSize, stdFrameHeader)) break;
        nTemp = ReadAMRFrameData(rfile,pos,maxLen, amrFrame, stdFrameSize, stdFrameHeader);
        if (!nTemp) {bErr = 1;break;}
        pos += nTemp;
		
		// 解码一个AMR音频帧成PCM数据 (8k-16b-单声道)
		Decoder_Interface_Decode(destate, amrFrame, pcmFrame, 0);
		nFrameCount++;
		//fwrite(pcmFrame, sizeof(short), PCM_FRAME_SIZE, fpwave);
        [fpwave appendBytes:pcmFrame length:PCM_FRAME_SIZE*sizeof(short)];
        }
	NSLog(@"frame = %d", nFrameCount);
	Decoder_Interface_exit(destate);
	
	//fclose(fpwave);
	
	// 重写WAVE文件头
	//fpwave = fopen([docFilePath cStringUsingEncoding:NSASCIIStringEncoding], "r+");
    //if (!bErr) {
        
    NSMutableData *out = [[NSMutableData alloc]init];
	WriteWAVEHeader(out, nFrameCount);
    [out appendData:fpwave];
	//fclose(fpwave);
	
	return out;
    //}
    
    // return data;
}


#pragma mark Encode
// 从WAVE文件读一个完整的PCM音频帧
// 返回值: 0-错误 >0: 完整帧大小
int ReadPCMFrameData(short speech[], char* fpwave, int nChannels, int nBitsPerSample)
{
	int nRead = 0;
	int x = 0, y=0;
//	unsigned short ush1=0, ush2=0, ush=0;
	
	// 原始PCM音频帧数据
	unsigned char  pcmFrame_8b1[PCM_FRAME_SIZE];
	unsigned char  pcmFrame_8b2[PCM_FRAME_SIZE<<1];
	unsigned short pcmFrame_16b1[PCM_FRAME_SIZE];
	unsigned short pcmFrame_16b2[PCM_FRAME_SIZE<<1];
	
    nRead = (nBitsPerSample/8) * PCM_FRAME_SIZE*nChannels;
	if (nBitsPerSample==8 && nChannels==1)
        {
		//nRead = fread(pcmFrame_8b1, (nBitsPerSample/8), PCM_FRAME_SIZE*nChannels, fpwave);
        memcpy(pcmFrame_8b1,fpwave,nRead);
		for(x=0; x<PCM_FRAME_SIZE; x++)
            {
			speech[x] =(short)((short)pcmFrame_8b1[x] << 7);
            }
        }
	else
		if (nBitsPerSample==8 && nChannels==2)
            {
			//nRead = fread(pcmFrame_8b2, (nBitsPerSample/8), PCM_FRAME_SIZE*nChannels, fpwave);
            memcpy(pcmFrame_8b2,fpwave,nRead);
            
			for( x=0, y=0; y<PCM_FRAME_SIZE; y++,x+=2 )
                {
				// 1 - 取两个声道之左声道
				speech[y] =(short)((short)pcmFrame_8b2[x+0] << 7);
				// 2 - 取两个声道之右声道
				//speech[y] =(short)((short)pcmFrame_8b2[x+1] << 7);
				// 3 - 取两个声道的平均值
				//ush1 = (short)pcmFrame_8b2[x+0];
				//ush2 = (short)pcmFrame_8b2[x+1];
				//ush = (ush1 + ush2) >> 1;
				//speech[y] = (short)((short)ush << 7);
                }
            }
		else
			if (nBitsPerSample==16 && nChannels==1)
                {
				//nRead = fread(pcmFrame_16b1, (nBitsPerSample/8), PCM_FRAME_SIZE*nChannels, fpwave);
                memcpy(pcmFrame_16b1,fpwave,nRead);
                
				for(x=0; x<PCM_FRAME_SIZE; x++)
                    {
					speech[x] = (short)pcmFrame_16b1[x+0];
                    }
                }
			else
				if (nBitsPerSample==16 && nChannels==2)
                    {
					//nRead = fread(pcmFrame_16b2, (nBitsPerSample/8), PCM_FRAME_SIZE*nChannels, fpwave);
                    memcpy(pcmFrame_16b2,fpwave,nRead);
                    
					for( x=0, y=0; y<PCM_FRAME_SIZE; y++,x+=2 )
                        {
						//speech[y] = (short)pcmFrame_16b2[x+0];
						speech[y] = (short)((int)((int)pcmFrame_16b2[x+0] + (int)pcmFrame_16b2[x+1])) >> 1;
                        }
                    }
	
	// 如果读到的数据不是一个完整的PCM帧, 就返回0
	return nRead;
}

// WAVE音频采样频率是8khz 
// 音频样本单元数 = 8000*0.02 = 160 (由采样频率决定)
// 声道数 1 : 160
//        2 : 160*2 = 320
// bps决定样本(sample)大小
// bps = 8 --> 8位 unsigned char
//       16 --> 16位 unsigned short
NSData* EncodePCMToAMR(char* data, NSInteger maxLen,int nChannels, int nBitsPerSample)
{
    char* oldBuf = data;
    /* input speech vector */
	short speech[160];
	
	/* counters */
	int byte_counter, frames = 0, bytes = 0;
	
	/* pointer to encoder state structure */
	void *enstate;
	
	/* requested mode */
	enum Mode req_mode = MR122;
	int dtx = 0;
	
	/* bitstream filetype */
	unsigned char amrFrame[MAX_AMR_FRAME_SIZE];

    NSMutableData* out = [[NSMutableData alloc]init];
	/* write magic number to indicate single channel AMR file storage format */
	//bytes = fwrite(AMR_MAGIC_NUMBER, sizeof(char), strlen(AMR_MAGIC_NUMBER), fpamr);
    [out appendBytes:AMR_MAGIC_NUMBER length:strlen(AMR_MAGIC_NUMBER)];
	
	/* skip to pcm audio data*/
	//SkipToPCMAudioData(fpwave);
	
	enstate = Encoder_Interface_init(dtx);
	
	while(1)
        {
		// read one pcm frame
        if ((data-oldBuf+320)>maxLen) {
            break;
        }
		int nRead = ReadPCMFrameData(speech, data, nChannels, nBitsPerSample);
        data += nRead;
        
		
		frames++;
		
		/* call encoder */
		byte_counter = Encoder_Interface_Encode(enstate, req_mode, speech, amrFrame, 0);
		
		bytes += byte_counter;
		//fwrite(amrFrame, sizeof (unsigned char), byte_counter, fpamr );
        [out appendBytes:amrFrame length:byte_counter];
        }
	
	Encoder_Interface_exit(enstate);
    
	return out;
}

//http://developer.apple.com/library/mac/#documentation/MusicAudio/Reference/CAFSpec/CAF_spec/CAF_spec.html#//apple_ref/doc/uid/TP40001862-CH210-SW1

//struct CAFFileHeader {
//    UInt32  mFileType;
//    UInt16  mFileVersion;
//    UInt16  mFileFlags;
//};
//
//struct CAFChunkHeader {
//    UInt32  mChunkType;
//    SInt64  mChunkSize;
//};

NSInteger SkipCaffHead(char* buf){
    
    if (!buf) {
        return 0;
    }
    char* oldBuf = buf;
    u32 mFileType = readUint32(buf);
    if (0x63616666!=mFileType) {
        return 0;
    }
    buf+=4;
    
//    u16 mFileVersion = readUInt16(buf);
    buf+=2;
//    u16 mFileFlags = readUInt16(buf);
    buf+=2;
    
    //desc free data
    u32 magics[3] = {0x64657363,0x66726565,0x64617461};
    for (int i=0; i<3; ++i) {
        u32 mChunkType = readUint32(buf);buf+=4;
        if (magics[i]!=mChunkType) {
            return 0;
        }
        
        s64 mChunkSize = readSint64(buf);buf+=8;
        if (mChunkSize<=0) {
            return 0;
        }
        if (i==2) {
            return buf-oldBuf;
        }
        buf += mChunkSize;
        
    }
    
    
    return 1;
}


//此处将一个录制的pcm直接转换为amr格式
//调用方式为 EncodeWAVEToAMR(pcmData,1,16);
NSData* EncodeWAVEToAMR(NSData* data, int nChannels, int nBitsPerSample)
{
    if (data==nil){
        return nil;
    }
    
    NSUInteger nPos  = 0;
    char* buf = (char *)[data bytes];
    NSUInteger maxLen = [data length];
    

    nPos += SkipCaffHead(buf);
    if (nPos>=maxLen) {
        return nil;
    }
    
    //这时取出来的是纯pcm数据
    buf += nPos;
    
    return EncodePCMToAMR(buf,maxLen- nPos,nChannels,nBitsPerSample);
}

