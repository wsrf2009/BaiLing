#ifndef		_FSK_Wav_Gen_API_H_
#define		_FSK_Wav_Gen_API_H_

#define		FSK_WIFI				(1)			//��ʾû�л��ѵ�wifi����
#define		FSK_ASR				(2)			//��ʾ���Ѽ�����
#define		ASR_START_NUM	(4)			//���Ѻ�ӵĻ���ʱ�䣬ÿһ����144ms������ʵ�ʾ���
#define		MAXBYTESLEN		(100)		//���͵�������ݳ���100�ַ�,13��
extern int WavLen;								//���ز��γ���
char* WavGen(
		char *BinData,							//byte����
		short len ,									//���ַ�����
		short ssidnum,							//�û�������
		short state,								//��������
        int *genLen
		);		
void WavGenFree();
unsigned short crc16(char *buffer, unsigned short len);//CRCУ��
#endif
