SELECT S.SKILL_NAME , S.SKILL_KEY
FROM INFOMART.dbo.SKILL S
WHERE S.SKILL_NAME LIKE '__' OR S.SKILL_NAME LIKE '%chat_a%'
OR S.SKILL_NAME LIKE '%superv%' OR S.SKILL_NAME LIKE '%mail_a%'