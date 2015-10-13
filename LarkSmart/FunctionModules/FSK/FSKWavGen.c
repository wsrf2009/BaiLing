#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdio.h>
#include "FSKWavGenAPI.h"

#define		CRC16				0x0101				//CRC�������
#define		SAMPLERATE			16000				//������16k
#define		FREQUENCY_ONE			5000				//ѡ��6��Ƶ��
#define		FREQUENCY_TWO			5250
#define		FREQUENCY_THREE			5500
#define		FREQUENCY_FOUR			5750
#define		FREQUENCY_FIVE			6000
#define		FREQUENCY_SIX			6250
#define		FREQUENCY_MID			4000
#define		PI				3.1415926
#define		TYPENUM				20						//����20���������
#define		DATALEN				2						//���ݳ���ռ�����ֽ�
#define		CRCLEN				2						//CRC16У��ռ�����ֽ�
#define		STARTEND			1						//1�ֽ�ͷβ
#define		FENGE					1						//ssid������ķָ���
#define		STARTASR				4						//��������  
#define		HALF_BYTE_DOT_NUM		1024		//4λ������������Ĳ�������	
#define		MIDWAV				128					//�м��һ�ι��Ȳ���
#define		MIDWAVMGC			100				//�м䲨�ε�����
#define		MAXMGC				29000				//ͳһ���������
#define		STATE_WIFI			(1)
#define		STATE_ASR			(2)
#define		FIRSTTYPE			(9)						//����ʱ���ӵ�Ƶ������
#define		SECONDTYPE		(9)
#define		ASRSTARTTYPE		(0)					//���ѿ�ʼͷ

void WavGenInit(short *wavdata,short *middata);
void	WavGenToMem(char *bytedata,short bytedatalen, char *validdata , short *initdata,short *Midwav,short ssidlen);
unsigned short crc16(char *buffer, unsigned short len);
void AddStartData(char *gendata,short *initdata,short *Midwav);

char *WavGenData=NULL;
int WavLen = 0  ;
void WavGenFree()
{
	if(WavGenData !=NULL)
	{
		free(WavGenData);
	}	
}
//���ɸ�����ɵĲ�������
//����:�沨�����ݵ�ָ�룬����������
void WavGenInit(short *wavdata,short *middata)
{
	int i = 0 , j = 0 ;
	short temp = 0 ;
	float maxtemp= 0 ;
	float tempmgc = 0 ;
	float sintemp[HALF_BYTE_DOT_NUM] = {0} ;	
	float con_mgc[HALF_BYTE_DOT_NUM] = {0};
	float fre_one = 0 ;
	float fre_two = 0 ;
	float fre_three = 0 ;
	float fre_four = 0 ;
	float fre_five = 0 ;
	float fre_six = 0 ;
	float fre_mid = 0 ;
	fre_one = (float)(2*PI*FREQUENCY_ONE)/(float)SAMPLERATE;
	fre_two = (float)(2*PI*FREQUENCY_TWO)/(float)SAMPLERATE;
	fre_three = (float)(2*PI*FREQUENCY_THREE)/(float)SAMPLERATE;
	fre_four = (float)(2*PI*FREQUENCY_FOUR)/(float)SAMPLERATE;
	fre_five = (float)(2*PI*FREQUENCY_FIVE)/(float)SAMPLERATE;
	fre_six = (float)(2*PI*FREQUENCY_SIX)/(float)SAMPLERATE;
	fre_mid = (float)(2*PI*FREQUENCY_MID)/(float)SAMPLERATE;
	
	for ( i= 0 ;i < MIDWAV ; i++)
	{
		temp = (short)(sin(i*fre_mid)*MIDWAVMGC);
		*(middata+i) = temp;
	}
	//�Ȱ�ϵ�����������
	for (j=0 ; j < HALF_BYTE_DOT_NUM;j++ )
	{
		con_mgc[j] = sin(PI*j/(float)HALF_BYTE_DOT_NUM);
	}

	for ( i =	0 ; i < TYPENUM ; i++)
	{	
		temp = 0 ;
		memset(sintemp,0,sizeof(float)*HALF_BYTE_DOT_NUM);
		maxtemp = 0 ;
		if( i == 0){
			//�������棬��ͳһ�Ŵ�
			for ( j=0 ; j < HALF_BYTE_DOT_NUM ; j++){
					sintemp[j] =con_mgc[j]*(sin(j*fre_one)+sin(j*fre_two) + sin(j*fre_three));
					if (sintemp[j] >= 0 )
						tempmgc = sintemp[j];		
					else
						tempmgc = 0.0 - sintemp[j];
					if ( tempmgc > maxtemp){
						maxtemp = tempmgc ;
					}
			}
		}else if ( i == 1){
			for ( j=0 ; j < HALF_BYTE_DOT_NUM ; j++){
				sintemp[j] = con_mgc[j]*(sin(j*fre_one)+sin(j*fre_two) + sin(j*fre_four));
				if (sintemp[j] >= 0 )
					tempmgc = sintemp[j];		
				else
					tempmgc = 0.0 - sintemp[j];
				if ( tempmgc > maxtemp){
					maxtemp = tempmgc ;
				}
			}
		}else if ( i == 2){
			for ( j=0 ; j < HALF_BYTE_DOT_NUM ; j++){
				sintemp[j] = con_mgc[j]*(sin(j*fre_one)+sin(j*fre_two) + sin(j*fre_five));
				if (sintemp[j] >= 0 )
					tempmgc = sintemp[j];		
				else
					tempmgc = 0.0 - sintemp[j];
				if ( tempmgc > maxtemp){
					maxtemp = tempmgc ;
				}
			}
		}else if ( i == 3){
			for ( j=0 ; j < HALF_BYTE_DOT_NUM ; j++){
				sintemp[j] = con_mgc[j]*(sin(j*fre_one)+sin(j*fre_two) + sin(j*fre_six));
				if (sintemp[j] >= 0 )
					tempmgc = sintemp[j];		
				else
					tempmgc = 0.0 - sintemp[j];
				if ( tempmgc > maxtemp){
					maxtemp = tempmgc ;
				}
			}
		}else if ( i == 4){
			for ( j=0 ; j < HALF_BYTE_DOT_NUM ; j++){
				sintemp[j] = con_mgc[j]*(sin(j*fre_one)+sin(j*fre_three) + sin(j*fre_four));
				if (sintemp[j] >= 0 )
					tempmgc = sintemp[j];		
				else
					tempmgc = 0.0 - sintemp[j];
				if ( tempmgc > maxtemp){
					maxtemp = tempmgc ;
				}
			}
		}else if ( i == 5){
			for ( j=0 ; j < HALF_BYTE_DOT_NUM ; j++){
				sintemp[j] = con_mgc[j]*(sin(j*fre_one)+sin(j*fre_three) + sin(j*fre_five));
				if (sintemp[j] >= 0 )
					tempmgc = sintemp[j];		
				else
					tempmgc = 0.0 - sintemp[j];
				if ( tempmgc > maxtemp){
					maxtemp = tempmgc ;
				}
			}
		}else if ( i == 6){
			for ( j=0 ; j < HALF_BYTE_DOT_NUM ; j++){
				sintemp[j] = con_mgc[j]*(sin(j*fre_one)+sin(j*fre_three) + sin(j*fre_six));
				if (sintemp[j] >= 0 )
					tempmgc = sintemp[j];		
				else
					tempmgc = 0.0 - sintemp[j];
				if ( tempmgc > maxtemp){
					maxtemp = tempmgc ;
				}
			}
		}else if ( i == 7){
			for ( j=0 ; j < HALF_BYTE_DOT_NUM ; j++){
				sintemp[j] = con_mgc[j]*(sin(j*fre_one)+sin(j*fre_four) + sin(j*fre_five));
				if (sintemp[j] >= 0 )
					tempmgc = sintemp[j];		
				else
					tempmgc = 0.0 - sintemp[j];
				if ( tempmgc > maxtemp){
					maxtemp = tempmgc ;
				}
			}
		}else if ( i == 8){
			for ( j=0 ; j < HALF_BYTE_DOT_NUM ; j++){
				sintemp[j] = con_mgc[j]*(sin(j*fre_one)+sin(j*fre_four) + sin(j*fre_six));
				if (sintemp[j] >= 0 )
					tempmgc = sintemp[j];		
				else
					tempmgc = 0.0 - sintemp[j];
				if ( tempmgc > maxtemp){
					maxtemp = tempmgc ;
				}
			}
		}else if ( i == 9){
			for ( j=0 ; j < HALF_BYTE_DOT_NUM ; j++){
				sintemp[j] = con_mgc[j]*(sin(j*fre_two)+sin(j*fre_three) + sin(j*fre_four));
				if (sintemp[j] >= 0 )
					tempmgc = sintemp[j];		
				else
					tempmgc = 0.0 - sintemp[j];
				if ( tempmgc > maxtemp){
					maxtemp = tempmgc ;
				}
			}
		}else if ( i == 10){
			for ( j=0 ; j < HALF_BYTE_DOT_NUM ; j++){
				sintemp[j] = con_mgc[j]*(sin(j*fre_two)+sin(j*fre_three) + sin(j*fre_five));
				if (sintemp[j] >= 0 )
					tempmgc = sintemp[j];		
				else
					tempmgc = 0.0 - sintemp[j];
				if ( tempmgc > maxtemp){
					maxtemp = tempmgc ;
				}
			}
		}else if ( i == 11){
			for ( j=0 ; j < HALF_BYTE_DOT_NUM ; j++){
				sintemp[j] = con_mgc[j]*(sin(j*fre_two)+sin(j*fre_three) + sin(j*fre_six));
				if (sintemp[j] >= 0 )
					tempmgc = sintemp[j];		
				else
					tempmgc = 0.0 - sintemp[j];
				if ( tempmgc > maxtemp){
					maxtemp = tempmgc ;
				}
			}
		}else if ( i == 12){
			for ( j=0 ; j < HALF_BYTE_DOT_NUM ; j++){
				sintemp[j] = con_mgc[j]*(sin(j*fre_two)+sin(j*fre_four) + sin(j*fre_five));
				if (sintemp[j] >= 0 )
					tempmgc = sintemp[j];		
				else
					tempmgc = 0.0 - sintemp[j];
				if ( tempmgc > maxtemp){
					maxtemp = tempmgc ;
				}
			}
		}else if ( i == 13){
			for ( j=0 ; j < HALF_BYTE_DOT_NUM ; j++){
				sintemp[j] = con_mgc[j]*(sin(j*fre_two)+sin(j*fre_four) + sin(j*fre_six));
				if (sintemp[j] >= 0 )
					tempmgc = sintemp[j];		
				else
					tempmgc = 0.0 - sintemp[j];
				if ( tempmgc > maxtemp){
					maxtemp = tempmgc ;
				}
			}
		}else if ( i == 14){
			for ( j=0 ; j < HALF_BYTE_DOT_NUM ; j++){
				sintemp[j] = con_mgc[j]*(sin(j*fre_two)+sin(j*fre_five) + sin(j*fre_six));
				if (sintemp[j] >= 0 )
					tempmgc = sintemp[j];		
				else
					tempmgc = 0.0 - sintemp[j];
				if ( tempmgc > maxtemp){
					maxtemp = tempmgc ;
				}
			}
		}else if ( i == 15){
			for ( j=0 ; j < HALF_BYTE_DOT_NUM ; j++){
				sintemp[j] = con_mgc[j]*(sin(j*fre_three)+sin(j*fre_four) + sin(j*fre_five));
				if (sintemp[j] >= 0 )
					tempmgc = sintemp[j];		
				else
					tempmgc = 0.0 - sintemp[j];
				if ( tempmgc > maxtemp){
					maxtemp = tempmgc ;
				}
			}
		}else if ( i == 16){
			for ( j=0 ; j < HALF_BYTE_DOT_NUM ; j++){
				sintemp[j] = con_mgc[j]*(sin(j*fre_three)+sin(j*fre_four) + sin(j*fre_six));
				if (sintemp[j] >= 0 )
					tempmgc = sintemp[j];		
				else
					tempmgc = 0.0 - sintemp[j];
				if ( tempmgc > maxtemp){
					maxtemp = tempmgc ;
				}
			}
		}else if ( i == 17){
			for ( j=0 ; j < HALF_BYTE_DOT_NUM ; j++){
				sintemp[j] = con_mgc[j]*(sin(j*fre_three)+sin(j*fre_five) + sin(j*fre_six));
				if (sintemp[j] >= 0 )
					tempmgc = sintemp[j];		
				else
					tempmgc = 0.0 - sintemp[j];
				if ( tempmgc > maxtemp){
					maxtemp = tempmgc ;
				}
			}
		}else if ( i == 18){
			for ( j=0 ; j < HALF_BYTE_DOT_NUM ; j++){
				sintemp[j] = con_mgc[j]*(sin(j*fre_one)+sin(j*fre_five) + sin(j*fre_six));
				if (sintemp[j] >= 0 )
					tempmgc = sintemp[j];		
				else
					tempmgc = 0.0 - sintemp[j];
				if ( tempmgc > maxtemp){
					maxtemp = tempmgc ;
				}
			}
		}else if ( i == 19){
			for ( j=0 ; j < HALF_BYTE_DOT_NUM ; j++){
				sintemp[j] = con_mgc[j]*(sin(j*fre_four)+sin(j*fre_five) + sin(j*fre_six));
				if (sintemp[j] >= 0 )
					tempmgc = sintemp[j];		
				else
					tempmgc = 0.0 - sintemp[j];
				if ( tempmgc > maxtemp){
					maxtemp = tempmgc ;
				}
			}
		}

		for ( j = 0 ; j < HALF_BYTE_DOT_NUM ; j++)
		{
			temp =(short)(MAXMGC/maxtemp*sintemp[j]);
			*(wavdata+i*HALF_BYTE_DOT_NUM+j) = temp;
		}
	}
}

//���ݲ�ͬ���Ͳ��θ��Ƶ���Ӧ��ַ
void	WavGenToMem(char *bytedata,short bytedatalen, char *validdata , short *initdata,short*Midwav,short ssidlen)
{
	int i = 0 , j = 0,k=0 ;
	char type = 0 , pretype = 20 ;
	char prepre = 0 ;
	char fenge = 0;
	int len = 0;

	for ( i = 0 ; i <bytedatalen ; i++ )
	{		
		if ( i == (ssidlen+DATALEN) )			//���׵�����Ⲩ����Ϊ�ָ���
		{	
			memcpy(validdata+(i*2)*2*HALF_BYTE_DOT_NUM+k*2*MIDWAV,Midwav,MIDWAV*2);
			k++;
			memcpy(validdata+(i*2)*2*HALF_BYTE_DOT_NUM+k*2*MIDWAV,initdata+(TYPENUM-2)*HALF_BYTE_DOT_NUM,HALF_BYTE_DOT_NUM*2);	
			fenge = 1;			//��Ƿָ�
			//continue;
		}
		type	= 0;
		for ( j = 0 ; j < 2 ;j++)
		{	
			if ( fenge == 0 ){
				len = (i*2+j)*2*HALF_BYTE_DOT_NUM;
			}else{
				len = (i*2+1+j)*2*HALF_BYTE_DOT_NUM;
			}
			memcpy(validdata+len+k*2*MIDWAV,Midwav,MIDWAV*2);		//������
			k++;
			if(j==0)
				type = ((*(bytedata+i))&0xF0)>>4;	//ǰ����ֽ�
			else	 
				type = (*(bytedata+i))&0x0F;		//�����ֽ�
			if ( pretype != type )						//ǰ��һ��
			{	
				prepre = 0 ;
				memcpy(validdata+len+k*2*MIDWAV , initdata+type*HALF_BYTE_DOT_NUM , HALF_BYTE_DOT_NUM*2);
			}
			else if(pretype == type && prepre == 0 )	//��ǰ����ͬ������ǰǰ��ͬ
			{	
				prepre = 1 ;
				memcpy(validdata+len+k*2*MIDWAV , initdata+16*HALF_BYTE_DOT_NUM , HALF_BYTE_DOT_NUM*2);
			}
			else if (pretype == type && prepre == 1 )	//��ǰǰ����ͬ
			{	
				prepre = 0 ;
				memcpy(validdata+len+k*2*MIDWAV , initdata+17*HALF_BYTE_DOT_NUM , HALF_BYTE_DOT_NUM*2);
			}
			pretype = type ;
		}//end for j
	} //end for i
	memcpy(validdata+(i*2+1)*2*HALF_BYTE_DOT_NUM+k*2*MIDWAV,Midwav,MIDWAV*2);		//���β��֮ǰ�ľ�����
}
void AddStartData(char *gendata,short *initdata,short *Midwav)
{
	int i = 0 ,j = 0,k=0;
	int len = 0 ;
	
	for ( i = 0 ; i < ASR_START_NUM ; i++)
	{	
		for ( j = 0 ; j < 2 ; j++)
		{	
			len = (i*2+j)*2*HALF_BYTE_DOT_NUM;
			if ( j == 0){
				memcpy(gendata+len+k*2*MIDWAV , initdata+FIRSTTYPE*HALF_BYTE_DOT_NUM , HALF_BYTE_DOT_NUM*2);
			}else if ( j == 1){
				memcpy(gendata+len+k*2*MIDWAV , initdata+SECONDTYPE*HALF_BYTE_DOT_NUM , HALF_BYTE_DOT_NUM*2);
			}
			memcpy(gendata+(i*2+j+1)*2*HALF_BYTE_DOT_NUM+k*2*MIDWAV,Midwav,MIDWAV*2);
			k++;
		}		
	}
}
//CRC16У��
unsigned short crc16(char *buffer, unsigned short len)
{
	unsigned short crc2 = 0;
	unsigned short c    = 0;
	unsigned short j    = 0;
	unsigned short crc	=	CRC16;

	while (len--)
	{
		crc2 = 0;
		c = (crc^ (*buffer++)) &0xff;

		for (j=0; j<8; j++)
		{
			if ( (crc2 ^ c) & 0x0001)
			{
				crc2 = (crc2 >> 1) ^ 0xA001;
			}
			else
			{
				crc2 =   crc2 >> 1;
			}
			c = c >> 1;
		}
		crc = (unsigned short) ( (crc >> 8) ^crc2);
	}

	return crc;
}

//�������ɵ�������
//�����Ƕ�������������ǲ��ε�����ֵ
char* WavGen(char *BinArray , short ByteLen , short ssidlen , short fskstate, int *genLen)
{
	int i=0/* , j=0 */;
	short *WavAllTypeData=NULL;      //�洢20�����͵Ĳ������ݣ���˳����
	unsigned short crc = 0 ;
	char *NewBinArray = NULL;			//�������ݳ��Ⱥ�У����������
	short allbyte = 0 ;
	short *Midwav =NULL;
	int cfglen = 0;
	char *b =NULL;
	int type = 0;

	WavAllTypeData =(short *) malloc(2*HALF_BYTE_DOT_NUM*TYPENUM);//һ��������ռ�����ֽ�
	//�������Ҫ���ŵ���������
	if ( fskstate == FSK_WIFI){
		WavLen = 2*HALF_BYTE_DOT_NUM*((ByteLen+STARTEND+CRCLEN+DATALEN)*2+FENGE)	+MIDWAV*2*((ByteLen+STARTEND+CRCLEN+DATALEN)*2);
		WavGenData = (char *)malloc(WavLen);
	}else if ( fskstate == FSK_ASR ){
		cfglen = 2*HALF_BYTE_DOT_NUM*((ByteLen+STARTEND+CRCLEN+DATALEN)*2+FENGE)	+MIDWAV*2*((ByteLen+STARTEND+CRCLEN+DATALEN)*2);
		WavLen = 2*HALF_BYTE_DOT_NUM*((ByteLen+STARTEND+CRCLEN+DATALEN+ASR_START_NUM)*2+FENGE+STARTASR)+MIDWAV*2*((ByteLen+STARTEND+CRCLEN+DATALEN+ASR_START_NUM)*2+STARTASR);
		WavGenData  = (char *)malloc(WavLen);
	}
	NewBinArray =	(char*)malloc(ByteLen+DATALEN+CRCLEN);
	Midwav = (short*)malloc(MIDWAV*2);
	memset(WavAllTypeData,0,2*HALF_BYTE_DOT_NUM*TYPENUM);
	memset(WavGenData,0,WavLen);
	memset(NewBinArray,0,ByteLen+DATALEN+CRCLEN);
	memset(Midwav,0,MIDWAV*2);
	//��ʼ������20�ֲ�������������һ�飬�Ժ�ֱ�Ӹ���
	WavGenInit(WavAllTypeData,Midwav);
	//���ݳ���+��Ч����+У��
	allbyte = ByteLen+DATALEN+CRCLEN;		//�ܵ����ݳ���
	memcpy(NewBinArray,&allbyte,sizeof(short));
	memcpy(NewBinArray+sizeof(short),BinArray,ByteLen);
	//CRC16У��
	crc=crc16(NewBinArray,ByteLen+sizeof(short));
	memcpy(NewBinArray+sizeof(short)+ByteLen,&crc,sizeof(short));			//�ܳ���+��Ч����+CRC
	//���Ͽ�ͷ
	memcpy(WavGenData,WavAllTypeData+(TYPENUM-2)*HALF_BYTE_DOT_NUM,HALF_BYTE_DOT_NUM*2);
	//��Ч����
	WavGenToMem(NewBinArray,ByteLen+DATALEN+CRCLEN,WavGenData+HALF_BYTE_DOT_NUM*2,WavAllTypeData,Midwav,ssidlen);
	//��β����
	memcpy(WavGenData+HALF_BYTE_DOT_NUM*2*((ByteLen+CRCLEN+DATALEN+FENGE)*2)+MIDWAV*2*((ByteLen+STARTEND+CRCLEN+DATALEN)*2),WavAllTypeData+(TYPENUM-1)*HALF_BYTE_DOT_NUM,HALF_BYTE_DOT_NUM*2);
	//���ӻ���ͷ������
	if (fskstate == FSK_ASR )
	{	
		//������Ч����
		b = (char *)malloc(cfglen*sizeof(char));
		memcpy(b,WavGenData,cfglen);
		memset(WavGenData,0,WavLen);
		memcpy(WavGenData+(WavLen-cfglen),b,cfglen);
		//��������ͷ������
		for ( i = 0 ; i < STARTASR ; i++)
		{	
			if ( i%2 == 0){
				type = ASRSTARTTYPE;
			}else{
				type = FIRSTTYPE;
			}
			memcpy(WavGenData+HALF_BYTE_DOT_NUM*2*i+MIDWAV*2*i,WavAllTypeData+type*HALF_BYTE_DOT_NUM,HALF_BYTE_DOT_NUM*2);
			memcpy(WavGenData+HALF_BYTE_DOT_NUM*2*(i+1)+MIDWAV*2*i,Midwav,MIDWAV*2);
		}
		//���ӹ�������
		AddStartData(WavGenData+HALF_BYTE_DOT_NUM*2*STARTASR+MIDWAV*2*STARTASR,WavAllTypeData,Midwav);
	}
	
	free(b);
	free(WavAllTypeData);
	free(NewBinArray);
	free(Midwav);
    *genLen = WavLen;
	return WavGenData ;
}
