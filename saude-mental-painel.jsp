<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.UUID" %>
<%
String tokenPainel=UUID.randomUUID().toString();
session.setAttribute("tokenPainelSaude",tokenPainel);
%>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Painel ao vivo — Saúde mental no trabalho</title>
<style>
:root{--verde:#0d4e3e}*{box-sizing:border-box}body{margin:0;min-height:100vh;overflow-x:hidden;background:radial-gradient(circle at 10% 15%,rgba(123,211,187,.32),transparent 30%),radial-gradient(circle at 90% 80%,rgba(253,198,99,.25),transparent 30%),#f4f9f7;color:#17352d;font-family:Arial,Helvetica,sans-serif}
header{position:sticky;top:0;z-index:20;display:grid;grid-template-columns:180px 1fr 260px;align-items:center;gap:18px;padding:14px 28px;background:rgba(255,255,255,.91);border-bottom:1px solid #d7e5df;backdrop-filter:blur(12px);box-shadow:0 5px 20px rgba(13,78,62,.06)}
.logo{width:150px;height:auto}.titulo{text-align:center}.titulo h1{margin:0;color:var(--verde);font-size:clamp(1.25rem,2.4vw,2.2rem)}.titulo p{margin:5px 0 0;color:#60736d}.status{text-align:right}.ao-vivo{display:inline-flex;align-items:center;gap:7px;font-weight:700;color:#176b57}.ponto{width:10px;height:10px;border-radius:50%;background:#21a179;box-shadow:0 0 0 0 rgba(33,161,121,.6);animation:pulso 1.8s infinite}.total{display:block;margin-top:5px;color:#60736d;font-size:.9rem}
.controles{display:flex;justify-content:flex-end;gap:7px;margin-bottom:8px}.controle{border:1px solid #cbdcd5;border-radius:999px;padding:8px 12px;background:#fff;color:#174c3d;font-weight:700;cursor:pointer}.controle:hover{background:#e2f1eb}.controle.perigo{color:#9b2c2c}.controle.perigo:hover{background:#fde8e8}
#mural{width:min(1500px,100%);margin:0 auto;padding:32px;columns:4 270px;column-gap:22px}.balao{--cor:#fff;position:relative;display:inline-block;width:100%;margin:0 0 22px;padding:clamp(20px,2.2vw,30px);break-inside:avoid;border:2px solid rgba(255,255,255,.8);border-radius:28px 28px 28px 8px;background:var(--cor);box-shadow:0 12px 30px rgba(38,72,62,.12);font-size:clamp(1rem,1.35vw,1.3rem);line-height:1.48;overflow-wrap:anywhere;animation:entrar .65s cubic-bezier(.2,.9,.25,1.25) both;transform:rotate(var(--giro))}
.balao::after{content:'“';position:absolute;right:16px;bottom:-17px;color:rgba(23,53,45,.12);font:700 72px Georgia,serif}.balao.destaque{font-size:clamp(1.2rem,1.7vw,1.55rem);font-weight:600}.vazio{display:grid;place-items:center;min-height:65vh;text-align:center;color:#60736d}.vazio div{max-width:560px}.vazio span{display:block;font-size:4rem;margin-bottom:15px;animation:flutuar 3s ease-in-out infinite}.erro{position:fixed;right:20px;bottom:20px;z-index:30;padding:14px 18px;border-radius:12px;background:#842029;color:#fff;box-shadow:0 8px 25px rgba(0,0,0,.18)}
.modal-fundo{position:fixed;inset:0;z-index:50;display:none;place-items:center;padding:20px;background:rgba(9,35,28,.58);backdrop-filter:blur(5px)}.modal-fundo.aberto{display:grid}.modal{width:min(620px,100%);padding:28px;border-radius:22px;background:#fff;box-shadow:0 24px 70px rgba(0,0,0,.25)}.modal h2{margin:0 0 10px;color:#0d4e3e}.modal p{color:#60736d}.modal textarea{width:100%;min-height:130px;padding:14px;border:2px solid #cbdcd5;border-radius:12px;font:1rem/1.5 Arial;resize:vertical}.modal-acoes{display:flex;justify-content:flex-end;gap:10px;margin-top:16px}.modal-acoes button{border:0;border-radius:999px;padding:11px 19px;font-weight:700;cursor:pointer}.cancelar{background:#e9efec;color:#31564c}.confirmar{background:#176b57;color:#fff}
@keyframes entrar{from{opacity:0;transform:translateY(35px) scale(.78) rotate(var(--giro))}to{opacity:1;transform:translateY(0) scale(1) rotate(var(--giro))}}@keyframes pulso{70%{box-shadow:0 0 0 10px rgba(33,161,121,0)}}@keyframes flutuar{50%{transform:translateY(-12px)}}@media(max-width:700px){header{grid-template-columns:70px 1fr 70px;padding:10px}.logo{width:68px}.titulo p{display:none}#mural{padding:18px;columns:1}.status .total{font-size:.72rem}}
</style>
</head>
<body>
<header>
<img class="logo" src="img/logo_andreza.png" alt="Andreza Almeida">
<div class="titulo"><h1 id="perguntaPainel">Saúde mental no ambiente de trabalho</h1><p>Respostas dos participantes</p></div>
<div class="status"><div class="controles"><button id="mudarPergunta" class="controle">Mudar pergunta</button><button id="limparRespostas" class="controle perigo">Limpar</button></div><span class="ao-vivo"><span class="ponto"></span> AO VIVO</span><span id="total" class="total">0 respostas</span></div>
</header>
<main id="mural" aria-live="polite"></main>
<div id="vazio" class="vazio"><div><span>💭</span><h2>Aguardando respostas...</h2><p>As contribuições aparecerão aqui automaticamente.</p></div></div>
<div id="modalPergunta" class="modal-fundo" role="dialog" aria-modal="true" aria-labelledby="tituloModal"><div class="modal"><h2 id="tituloModal">Mudar pergunta</h2><p>A nova pergunta substituirá imediatamente a atual no formulário dos participantes.</p><textarea id="novaPergunta" maxlength="500"></textarea><div class="modal-acoes"><button type="button" id="cancelarPergunta" class="cancelar">Cancelar</button><button type="button" id="salvarPergunta" class="confirmar">Salvar pergunta</button></div></div></div>
<script>
const tokenPainel='<%= tokenPainel %>';
const cores=['#dff3ea','#fff0c7','#dceeff','#f5dcf0','#e8e2ff','#ffe0d5','#e5f0cf','#d9f2f2'];
const mural=document.getElementById('mural'),vazio=document.getElementById('vazio'),totalEl=document.getElementById('total'),perguntaEl=document.getElementById('perguntaPainel');
let maiorId=0,carregando=false;
function criarBalao(item,inicial){
 const el=document.createElement('article'),indice=item.id%cores.length;
 el.className='balao'+(item.texto.length<65?' destaque':'');
 el.style.setProperty('--cor',cores[indice]);
 el.style.setProperty('--giro',((item.id%7)-3)*.45+'deg');
 if(inicial)el.style.animationDelay=Math.min(mural.children.length*.06,1.2)+'s';
 el.textContent=item.texto;
 if(inicial)mural.appendChild(el);else mural.insertBefore(el,mural.firstChild);
 maiorId=Math.max(maiorId,item.id);
}
async function atualizar(){
 if(carregando)return;carregando=true;
 try{
   const resposta=await fetch('saude-mental-respostas-api.jsp?depois='+maiorId,{cache:'no-store'});
   if(!resposta.ok)throw new Error('Falha HTTP '+resposta.status);
   const dados=await resposta.json();
   const inicial=maiorId===0;
   let itens=dados.respostas||[];
   if(dados.pergunta)perguntaEl.textContent=dados.pergunta;
   if(inicial)itens=itens.reverse();
   itens.forEach(item=>criarBalao(item,inicial));
   vazio.style.display=dados.total>0?'none':'grid';
   totalEl.textContent=dados.total+' '+(dados.total===1?'resposta':'respostas');
   document.querySelector('.erro')?.remove();
 }catch(e){
   if(!document.querySelector('.erro')){const el=document.createElement('div');el.className='erro';el.textContent='Reconectando ao painel...';document.body.appendChild(el)}
 }finally{carregando=false}
}
async function acaoPainel(parametros){
 const corpo=new URLSearchParams(Object.assign({token:tokenPainel},parametros));
 const resposta=await fetch('saude-mental-respostas-api.jsp',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8'},body:corpo});
 const dados=await resposta.json();
 if(!resposta.ok||!dados.ok)throw new Error(dados.mensagem||'Não foi possível concluir a operação.');
 return dados;
}
document.getElementById('limparRespostas').addEventListener('click',async function(){
 if(!confirm('Deseja realmente apagar todas as respostas exibidas? Esta ação não pode ser desfeita.'))return;
 try{await acaoPainel({acao:'limpar'});mural.replaceChildren();maiorId=0;totalEl.textContent='0 respostas';vazio.style.display='grid';}catch(e){alert(e.message)}
});
const modal=document.getElementById('modalPergunta'),campoPergunta=document.getElementById('novaPergunta');
document.getElementById('mudarPergunta').addEventListener('click',function(){campoPergunta.value=perguntaEl.textContent;modal.classList.add('aberto');campoPergunta.focus()});
document.getElementById('cancelarPergunta').addEventListener('click',function(){modal.classList.remove('aberto')});
modal.addEventListener('click',function(e){if(e.target===modal)modal.classList.remove('aberto')});
document.getElementById('salvarPergunta').addEventListener('click',async function(){
 const pergunta=campoPergunta.value.trim();if(pergunta.length<5){alert('Digite uma pergunta com pelo menos 5 caracteres.');return}
 try{const dados=await acaoPainel({acao:'pergunta',pergunta:pergunta});perguntaEl.textContent=dados.pergunta;modal.classList.remove('aberto')}catch(e){alert(e.message)}
});
atualizar();setInterval(atualizar,2500);
</script>
</body>
</html>
