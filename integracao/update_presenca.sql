select i.`Data` ,i.Nome ,i.Telefone, date_format(`i`.`Data`, '%Y%m%d') as dtFormatada
,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(i.telefone, '(', ''), ')', ''), '-', ''), ' ', ''), '.', ''), '+', ''), '/', ''),',0',''),'_','')  AS telefone_formatado 
,LENGTH(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(i.telefone, '(', ''), ')', ''), '-', ''), ' ', ''), '.', ''), '+', ''), '/', ''),',0',''),'_','')) 
, RIGHT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(i.telefone, '(', ''), ')', ''), '-', ''), ' ', ''), '.', ''), '+', ''), '/', ''),',0',''),'_',''),8) AS fone_pesq
  
from integra_presenca i
ORDER BY 6

select Idpessoa, nome, fone1, RIGHT(fone1,8)  
from pessoas p 

select  * from participanteEncontro pe 

select e.idEncontro, e.Classe, e.Descricao, e.DtEncontro, pe.IdPessoa , pe.flgPresenca   
, i.`Data` ,i.Nome ,i.Telefone, date_format(`i`.`Data`, '%Y%m%d') as dtFormatada
,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(i.telefone, '(', ''), ')', ''), '-', ''), ' ', ''), '.', ''), '+', ''), '/', ''),',0',''),'_','')  AS telefone_formatado 
,LENGTH(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(i.telefone, '(', ''), ')', ''), '-', ''), ' ', ''), '.', ''), '+', ''), '/', ''),',0',''),'_','')) 
, RIGHT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(i.telefone, '(', ''), ')', ''), '-', ''), ' ', ''), '.', ''), '+', ''), '/', ''),',0',''),'_',''),8) AS fone_pesq  
from integra_presenca i 
	inner join Encontros e on (date_format(`i`.`Data`, '%Y%m%d') = date_format(`e`.`DtEncontro`, '%Y%m%d') )
	inner join participanteEncontro pe on pe.IdEncontro = e.IdEncontro 
	left join pessoas p on RIGHT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(i.telefone, '(', ''), ')', ''), '-', ''), ' ', ''), '.', ''), '+', ''), '/', ''),',0',''),'_',''),8) = RIGHT(p.Fone1,8) and e.Classe  = p.Classe  
	
ORDER BY 6 

--------------------------------------------------------

select i.`Data` ,i.Nome ,i.Telefone, date_format(`i`.`Data`, '%Y%m%d') as dtFormatada
, RIGHT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(i.telefone, '(', ''), ')', ''), '-', ''), ' ', ''), '.', ''), '+', ''), '/', ''),',0',''),'_',''),8) AS fone_pesq  
, p.IdPessoa , p.Nome , p.Fone1 
, e.IdEncontro , e.Descricao , pe.flgPresenca 
from integra_presenca i 
	left join pessoas p on RIGHT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(i.telefone, '(', ''), ')', ''), '-', ''), ' ', ''), '.', ''), '+', ''), '/', ''),',0',''),'_',''),8) = RIGHT(p.Fone1,8)   
	inner join Encontros e on (date_format(`i`.`Data`, '%Y%m%d') = date_format(`e`.`DtEncontro`, '%Y%m%d') )
	inner join participanteEncontro pe on pe.IdEncontro = e.IdEncontro and pe.IdPessoa = p.IdPessoa 


UPDATE  participanteEncontro pe
JOIN Encontros e 
    ON pe.IdEncontro = e.IdEncontro
JOIN pessoas p 
    ON pe.IdPessoa = p.IdPessoa
JOIN integra_presenca i 
    ON RIGHT(
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(i.telefone, 
            '(', ''), ')', ''), '-', ''), ' ', ''), '.', ''), '+', ''), '/', ''), ',0',''),'_',''),8
       ) = RIGHT(
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(p.Fone1, 
            '(', ''), ')', ''), '-', ''), ' ', ''), '.', ''), '+', ''), '/', ''), ',0',''),'_',''),8
       )
   AND DATE_FORMAT(i.Data, '%Y%m%d') = DATE_FORMAT(e.DtEncontro, '%Y%m%d')
 SET pe.flgPresenca = 1
WHERE pe.IdEncontro = 30;