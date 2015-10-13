#ifndef		_FSK_Wav_Gen_API_H_
#define		_FSK_Wav_Gen_API_H_

#define		FSK_WIFI				(1)			//表示没有唤醒的wifi配置
#define		FSK_ASR				(2)			//表示唤醒加配置
#define		ASR_START_NUM	(4)			//唤醒后加的缓冲时间，每一遍是144ms，根据实际决定
#define		MAXBYTESLEN		(100)		//发送的最大数据长度100字符,13秒
extern int WavLen;								//返回波形长度
char* WavGen(
		char *BinData,							//byte数据
		short len ,									//总字符长度
		short ssidnum,							//用户名长度
		short state,								//配置类型
        int *genLen
		);		
void WavGenFree();
unsigned short crc16(char *buffer, unsigned short len);//CRC校验
#endif
