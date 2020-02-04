SELECT DATE.LABEL_YYYY_MM_DD AS Date,
cast(DATEADD(hour,2,DATE.CAL_DATE) AS time(0)) AS "Hours",
		VQ.RESOURCE_NAME AS Language,
		COUNT (DISTINCT IRF.INTERACTION_ID) AS 'Inbound calls',
		COUNT (DISTINCT CASE WHEN TD.TECHNICAL_RESULT='Transferred' THEN IRF.INTERACTION_ID END) AS 'Transferred', --���-�� ������������ �������
		/* Mediation Duration (c������ ��� ASA)- �������� ����� � ��������, � ������� �������� �������������� � �������� ����������� � �������������� 
		(� ��������, ������ ������������� ��� IVR, �� ��������� � �����������������) �� ���������� �������, ��������������� ������� IRF. 
		��� ����� ���������� �� ������� ������ �������� IRF �� �������, ����� �������������� ��������� �������, ��������������� ������� IRF*/
		ROUND(SUM(IRF.TALK_DURATION)/SUM(IRF.TALK_COUNT),2) AS 'AVG Talk Time, sec',--���������� ������, ������� IVR ���������������� ��� ������ ������ �������� �� �������� �� ����� ���������� ��������������.
		ROUND(SUM(IRF.RING_DURATION)/SUM(IRF.TALK_COUNT),2) AS 'AVG Ring Dutation, sec',--���������� ������, � ������� ������� ��������� �������������� ������� �� IVR ���������������� ��� ������� ������
		ROUND(SUM(IRF.HOLD_DURATION)/SUM(IRF.TALK_COUNT),2) AS 'AVG Hold Time, sec',--���������� ������, � ������� ������� ������, ��������� � ���� ��������� ���������������, ��������� �������������� � ����� ���������
		CASE WHEN SUM(IRF.AFTER_CALL_WORK_COUNT)>0 THEN ROUND(SUM(IRF.AFTER_CALL_WORK_DURATION)/SUM(IRF.TALK_COUNT),2) ELSE '' END AS 'AVG After Call Work Time, sec',--���������� ������, � ������� ������� ������ IRF, ��������� � ���� ��������� ���������������, ��������� � ��������� ACW
		ROUND(SUM(IRF.TALK_DURATION+IRF.HOLD_DURATION+IRF.AFTER_CALL_WORK_DURATION )/SUM(IRF.TALK_COUNT),2) AS 'AHT, sec'
				
FROM INTERACTION_RESOURCE_FACT AS IRF
		INNER JOIN INTERACTION_TYPE AS IT ON IRF.INTERACTION_TYPE_KEY=IT.INTERACTION_TYPE_KEY
		INNER JOIN TECHNICAL_DESCRIPTOR AS TD ON IRF.TECHNICAL_DESCRIPTOR_KEY=TD.TECHNICAL_DESCRIPTOR_KEY
		INNER JOIN DATE_TIME AS DATE ON IRF.START_DATE_TIME_KEY=DATE.DATE_TIME_KEY
		LEFT JOIN MEDIA_TYPE AS MT ON IRF.MEDIA_TYPE_KEY=MT.MEDIA_TYPE_KEY
					--������������ ������� ��� ��������� ������ (������� �������)
		INNER JOIN RESOURCE_ AS R ON IRF.RESOURCE_KEY=R.RESOURCE_KEY
		INNER JOIN RESOURCE_ VQ ON IRF.LAST_VQUEUE_RESOURCE_KEY=VQ.RESOURCE_KEY
		

			
WHERE DATE.LABEL_YYYY_MM_DD >='2019-11-01'
	AND IRF.TALK_COUNT>0
 	AND IT.INTERACTION_TYPE='Inbound'
	AND MT.MEDIA_NAME='Voice'
	AND VQ.RESOURCE_NAME<>'NONE'
	AND VQ.RESOURCE_NAME<>'VQ_Test_Phone_Inbound'
	AND VQ.RESOURCE_NAME<>'VQ_RU_Phone_Inbound'
	AND R.AGENT_FIRST_NAME IS NOT NULL
	AND R.AGENT_FIRST_NAME!='%����%'
		
GROUP BY DATE.LABEL_YYYY_MM_DD,DATE.CAL_DATE,VQ.RESOURCE_NAME

ORDER BY DATE.LABEL_YYYY_MM_DD, DATE.CAL_DATE