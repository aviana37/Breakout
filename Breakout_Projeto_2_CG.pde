////////////////////////////////////////////////////
//                                                //
//               JOGO    BREAKOUT                 //
//                                                //
//   Componentes: André Viana     - 25037         //
//                Tamiris Fonseca - 23925         //
//                Henrique Gusmão - 16622         //
//                                                //
//   Data: 05/05/2015                             //
//                                                //
//   Descrição: Tente quebrar todos os tijolos    //
//              sem deixar a bolinha cair. Mova   //
//              a plataforma utilizando as setas  //
//              do teclado.                       //
//                                                //
////////////////////////////////////////////////////

//Áudio e ícone do aplicativo.
import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;
import javax.swing.ImageIcon;

//Constantes do jogo:
//Tamanho da tela
final int resolucao_x = 640;
final int resolucao_y = 480;

//Layout do jogo
final int espacoPlacar = 50;
final int larguraBorda = 35;
final int alturaBorda = resolucao_y - espacoPlacar;

//Espaço de movimentação da bola
final int maxy = resolucao_y;
final int maxx = resolucao_x  - larguraBorda;
final int minx = larguraBorda;
final int miny = espacoPlacar + larguraBorda;

//Bola
final int raioBola = 10;
final float velocidadeBola_x = 6.3;
final float velocidadeBola_y = 6.3;

//Bloco
final int larguraBloco = 20;
final int alturaBloco = 10;
final int maxColunas = 25;
final int maxLinhas  = 7;

//Plataforma
final int larguraPlataforma = 60;
final int alturaPlataforma = 10;
final int velocidadePlataforma = 10;

//Vidas
final int maxVidas = 10;
final int maxFases = 6;

//Sons do jogo
AudioPlayer[] sons;

//Classes
class Bloco {
  PVector pos;
  boolean visible;

  Bloco (int x, int y) {
    pos = new PVector(x, y);
    visible = false;
  }
  //Não se desenha se estiver invisível.
  void desenhar() {
    if(visible)
      rect(pos.x, pos.y, larguraBloco, alturaBloco);
  }
}
class Bola
{
  PVector pos;
  PVector speed;
  boolean morta;

  Bola()
  {
    pos = new PVector();
    speed = new PVector();
    morta = false;
  }

  //Desenha a bola caso ela não esteja morta.
  void desenhar()
  {
    if (!morta) {
      fill(255, 0, 0);
      ellipse(pos.x, pos.y, raioBola*2, raioBola*2);
    }
  }
  //Atualiza a posição da bola caso ela não esteja morta.
  void mover() {
    if (!morta)
    {
      //Mover-se a partir da velocidade.
      pos.add(speed);
      
      //Caso a bola bata em uma das quinas ela quica
      if (pos.x > (maxx-raioBola) || pos.x < (minx+raioBola))
      {
        speed.x *= -1;
        if (pos.x > (maxx-raioBola))
          pos.x = maxx-raioBola;
        if (pos.x < (minx+raioBola))
          pos.x = minx+raioBola;
  
        sons[3].play();
        sons[3].rewind();
      }
      //Se ela bater na parte de cima da tela.
      else if (pos.y < (miny+raioBola))
      {
        speed.y *= -1;
        pos.y = miny + raioBola;
  
        sons[3].play();
        sons[3].rewind();
      }
      //Se ela escapar da área de movimentação.
      else if (pos.y > (maxy+(raioBola*2)))
        morrer();
    }
  }
  void morrer()
  {
    --vidas;
   
    //Se não houver mais vidas, finalizar o jogo com a tela de derrota.
    if (vidas==0)
      finalizarJogo(false);
    //Caso contrário, adotar estado de morte.
    else
    {
      morta = true;
      sons[5].play();
      sons[5].rewind();
    }
  }
  //Inicializa a bola na posição especificada. 
  void inicializar(int x, int y) {
    if (vidas > 0) {
      pos.set(x, y);
      speed.y = -velocidadeBola_y;
    }
  }
}
class Plataforma
{
  int pos;
  boolean dir, esq, mouse;

  //Inicializa a plataforma no meio da tela.
  Plataforma()
  {
    pos = width/2;
    pos -= larguraPlataforma/2;
    dir = esq = mouse = false;
  }

  //Marca para qual direção a plataforma deve se mover.
  void setDirecao(boolean esq, boolean dir, boolean mouse)
  {
    this.esq = esq;
    this.dir = dir;
    this.mouse = mouse;
  }

  //Movimenta a plataforma de acordo com a direção especificada.
  void update()
  {
    if (dir)
      pos += velocidadePlataforma;
    if (esq)
      pos -= velocidadePlataforma;

    //Se o direcionamento vier do mouse é necessário zerar as variáveis a cada ciclo.
    if (mouse)
      dir = esq = mouse = false;

    //Assegurando que a plataforma fique dentro da área de movimentação.
    if (pos < minx)
      pos = minx;
    else if (pos > maxx-larguraPlataforma)
      pos = maxx-larguraPlataforma;
  }

  //Desenha a plataforma na cor branca.
  void desenhar()
  {
    fill(255);
    rect(pos, height-alturaPlataforma, larguraPlataforma, alturaPlataforma);
  }
}



//Métodos de colisão círculo -> retângulo
boolean colisao(Bola bola, Plataforma plataforma)
{
  //Calculando distância entre o centro da bola e da plataforma.
  PVector distancia = new PVector(0, 0);
  float auxx = bola.pos.x - (plataforma.pos+larguraPlataforma/2);
  float auxy = bola.pos.y - (height-alturaPlataforma/2);
  distancia.set(abs(auxx), abs(auxy));

  //Avaliando distância entre o centro da bola e da plataforma.

  //Se a plataforma estiver completamente fora do bloco.
  if (distancia.x > larguraPlataforma/2+raioBola)
    return false;
  if (distancia.y > alturaPlataforma/2+raioBola)
    return false;

  //Se a plataforma estiver dentro do bloco.
  if (distancia.x <= (larguraPlataforma/2)) {
    if (bola.pos.x < plataforma.pos+10)
      bola.speed.set(-6.3,6.3);
    else if (bola.pos.x < plataforma.pos+20)
      bola.speed.set(-4.45,7.7);
    else if (bola.pos.x < plataforma.pos+30)
      bola.speed.set(-2.3,8.6);
    else if (bola.pos.x < plataforma.pos+40)
      bola.speed.set(2.3,8.6);
    else if (bola.pos.x < plataforma.pos+50)
      bola.speed.set(4.45,7.7);
    else if (bola.pos.x < plataforma.pos+60)
      bola.speed.set(6.3,6.3);
    return true;
  }

  if (distancia.y <= (alturaPlataforma/2))
    return true;

  //Caso mais difícil, quando a plataforma está próxima de um dos cantos da bola.
  float distanciaAbsoluta=pow(distancia.x - larguraPlataforma/2, 2)+
    pow(distancia.y - alturaPlataforma/2, 2);

  return (distanciaAbsoluta <= pow(raioBola, 2));
}
boolean colisao(Bola bola, Bloco bloco)
{
  //Se o bloco estiver visível.
  if (bloco.visible) {

    //Calculando distância entre o centro da bola e do bloco.
    PVector distancia = new PVector(0, 0);
    float auxx = bola.pos.x - (bloco.pos.x+larguraBloco/2);
    float auxy = bola.pos.y - (bloco.pos.y+alturaBloco/2);
    distancia.set(abs(auxx), abs(auxy));

    //Avaliando distância entre o centro da bola e do bloco.

    //Se a bola estiver completamente fora do bloco.
    if (distancia.x > larguraBloco/2+raioBola)
      return false;
    if (distancia.y > alturaBloco/2+raioBola)
      return false;

    //Se a bola estiver dentro do bloco.
    if (distancia.x <= (larguraBloco/2)) {
      bola.speed.y *= -1;
      return true;
    }
    if (distancia.y <= (alturaBloco/2)) {
      bola.speed.x *= -1;
      return true;
    }

    //Caso mais difícil, quando o bloco está próximo de um dos cantos da bola.
    float distanciaAbsoluta=pow(distancia.x - larguraBloco/2, 2)+
      pow(distancia.y - alturaBloco/2, 2);

    return (distanciaAbsoluta <= pow(raioBola, 2));
  }
  return false;
}



//Variáveis do jogo
int [][][] fases = 
  {
    {
      {0,0,0,0,0,0,0,0,0,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0},
      {0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,1,0,0,0,0,0,0,0,0,0},
      {0,0,0,0,0,0,0,0,1,0,1,1,1,1,1,0,1,0,0,0,0,0,0,0,0},
      {0,0,0,0,0,0,0,1,0,1,1,1,1,1,1,1,0,1,0,0,0,0,0,0,0},
      {0,0,0,0,0,0,0,0,1,0,1,1,1,1,1,0,1,0,0,0,0,0,0,0,0},
      {0,0,0,0,0,0,0,0,0,1,0,1,1,1,0,1,0,0,0,0,0,0,0,0,0},
      {0,0,0,0,0,0,0,0,0,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0}
    },
    {
      {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
      {1,1,1,1,0,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,0,1,1,1,1},
      {1,1,1,0,0,0,1,1,1,1,1,0,0,0,1,1,1,1,1,0,0,0,1,1,1},
      {1,1,0,0,0,0,0,1,1,1,0,0,0,0,0,1,1,1,0,0,0,0,0,1,1},
      {1,1,1,0,0,0,1,1,1,1,1,0,0,0,1,1,1,1,1,0,0,0,1,1,1},
      {1,1,1,1,0,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,0,1,1,1,1},
      {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
    },
    {
      {0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0},
      {0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0},
      {0,1,1,1,1,1,1,1,0,0,0,0,1,0,0,0,0,1,1,1,1,1,1,1,0},
      {0,1,1,1,1,1,1,1,1,0,0,1,1,1,0,0,1,1,1,1,1,1,1,1,0},
      {0,1,1,1,1,1,1,1,0,0,0,0,1,0,0,0,0,1,1,1,1,1,1,1,0},
      {0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0},
      {0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0}
    },
    {
      {0,1,0,0,1,0,1,0,0,1,0,1,0,1,1,1,1,0,1,1,1,1,0,1,0},
      {0,1,0,0,1,0,1,0,0,1,0,1,0,1,0,0,0,0,1,0,0,0,0,1,0},
      {0,1,0,0,1,0,1,0,0,1,0,1,0,1,0,0,0,0,1,0,0,0,0,1,0},
      {0,1,0,0,1,0,1,1,0,1,0,1,0,1,1,1,1,0,1,1,1,1,0,1,0},
      {0,1,0,0,1,0,1,0,1,1,0,1,0,1,0,0,0,0,1,0,0,0,0,1,0},
      {0,1,0,0,1,0,1,0,0,1,0,1,0,1,0,0,0,0,1,0,0,0,0,1,0},
      {0,1,1,1,1,0,1,0,0,1,0,1,0,1,0,0,0,0,1,1,1,1,0,1,0},
    },
    {
      {1,1,1,1,1,1,1,0,0,0,0,0,1,0,0,0,0,0,1,1,1,1,1,1,1},
      {1,1,1,1,1,1,0,0,0,0,0,1,1,1,0,0,0,0,0,1,1,1,1,1,1},
      {1,1,1,1,1,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,1,1,1,1,1},
      {1,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,1,1,1,1},
      {1,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,1},
      {1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1},
      {1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1}
    },
    {
      {0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0},
      {0,0,0,0,0,1,0,0,0,0,1,0,0,0,1,0,0,0,0,1,0,0,0,0,0},
      {0,0,0,0,1,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,1,0,0,0,0},
      {0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0},
      {0,0,0,0,1,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,1,0,0,0,0},
      {0,0,0,0,0,1,0,0,0,0,1,0,0,0,1,0,0,0,0,1,0,0,0,0,0},
      {0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0}
    }
  };
Bloco[][] blocos;
Bola bola;
Plataforma plataforma;
PImage vitoria, derrota, heart;
boolean mostrarVitoria, mostrarDerrota, pausado;
int vidas;
int placar;
int faseAtual;
int totalBolas;
Minim minim;



//Marca os blocos da fase atual como visíveis e atualiza o valor total de bolas na tela.
void inicializarFaseAtual()
{
  totalBolas = 0;
  for (int i = 0; i < maxLinhas; i++) {
    for (int j = 0; j < maxColunas; j++) {
      blocos[i][j].visible = (fases[faseAtual][i][j] > 0);
        ++totalBolas;
    }
  }
}

//Inicia as variáveis do jogo na fase 0.
void inicializarJogo()
{
  faseAtual = 0;
  inicializarFaseAtual();
  
  vidas = maxVidas;
  placar = 0;

  mostrarVitoria = false;
  mostrarDerrota = false;
  pausado = true;
  
  bola.inicializar((plataforma.pos+larguraPlataforma/2), 
                  (height-raioBola-1)-alturaPlataforma);
}

//Inicializa a tela de vitória, derrota, ou a próxima fase.
void finalizarJogo(boolean vitoria)
{
  if (vitoria) {
    ++faseAtual;
    //Caso existam mais fases para serem jogadas.
    if(faseAtual < maxFases)
    {
      bola.morta = true;
      vidas += maxVidas;
      inicializarFaseAtual();
    }
    //Caso contrário encerre o jogo com vitória.
    else
    {
      sons[8].play();
      sons[8].rewind();
      mostrarVitoria = true;
    }
  } 
   //Inicializa tela de derrota.
   else {
    sons[6].play();
    sons[6].rewind();
    mostrarDerrota = true;
  }
}

//Desenha texto de ajuda no centro da tela.
void drawAjuda()
{
  textAlign(CENTER);
  textSize(32);
  text("APERTE ESPACO PARA COMECAR", resolucao_x/2, resolucao_y/2);
  text("USE AS SETAS/MOUSE PARA MOVER", resolucao_x/2, resolucao_y/2 + 40);
}
//Desenha a tela de vitória.
void drawVitoria()
{
  background(255);

  fill(0, 0, 255);
  textAlign(CENTER);
  textSize(38);
  text("VOCE GANHOU!", resolucao_x/2, resolucao_y/2 + 100);
  textSize(32);
  text(placar*vidas + " PONTOS", resolucao_x/2, resolucao_y/2 + 150);
  textSize(20);
  text("APERTE ESPACO PARA RECOMECAR", resolucao_x/2, resolucao_y/2 +220);
  image(vitoria, resolucao_x/2 - 50, resolucao_y/2-50, 100, 100);
}
//Desenha a tela de derrota.
void drawDerrota()
{
  background(0);

  fill(255);
  textAlign(CENTER);
  textSize(38);
  text("GAME OVER", resolucao_x/2, resolucao_y/2 + 100);
  textSize(24);
  text(placar + " PONTOS", resolucao_x/2, resolucao_y/2 + 150);
  textSize(20);
  text("APERTE ESPACO PARA RECOMECAR", resolucao_x/2, resolucao_y/2 +220);
  image(derrota, resolucao_x/2-50, resolucao_y/2-50, 100, 100);
}
//Desenha a tela de jogo.
void drawJogo()
{
  //Limpar tela.
  background(0);

  //Pontuação.
  textAlign(CENTER);
  textSize(48);
  text(placar, resolucao_x/2, 45);
  //Fase atual e vidas.
  textSize(42);
  text("FASE " + (faseAtual+1), resolucao_x/2 - 200, 45);
  text(vidas, resolucao_x/2+210, 45);
  image(heart, resolucao_x/2+230, 10);

  //Desenhando bordas da tela.
  fill(150);
  rect(0, espacoPlacar, larguraBorda, alturaBorda);
  rect(maxx, espacoPlacar, larguraBorda, alturaBorda);
  rect(0, espacoPlacar, resolucao_x, larguraBorda);

  //Desenhando blocos. Quando um bloco é invisível, ele não se desenha.
  for (int i = 0; i < maxLinhas; i++) {
    for (int j = 0; j < maxColunas; j++) {
      if (i == 0) fill(211,0,0);
      else if (i == 1) fill(255,106,0);
      else if (i == 2) fill(255,216,0);
      else if (i == 3) fill(182,255,0);
      else fill(76,255,0);
      blocos[i][j].desenhar();
    }
  }
  //Desenhando bola e plataforma.
  bola.desenhar();
  plataforma.desenhar();
}

//Atualiza o jogo, tratando colisões e movimento das entidades.
void update()
{
  //Atualizar lógica da bola e da plaforma.
  if (bola.morta)
  {
    bola.inicializar(plataforma.pos+larguraPlataforma/2, 
                    (height-raioBola-1)-alturaPlataforma);
  }
  if (bola.morta == false)
    bola.mover();
  plataforma.update();

  //Colidir com a plataforma;
  if (colisao(bola, plataforma))
  {
    bola.speed.y *= -1;
    bola.pos.y = (height - raioBola-1)-alturaPlataforma;
    sons[4].play();
    sons[4].rewind();
  }
  //Verificar colisões, marcando como invisível blocos que estão colidindo com a bola.
  for (int i = 0; i < maxLinhas; i++) {
    for (int j = 0; j < maxColunas; j++) {
      if (colisao(bola, blocos[i][j])) {
        blocos[i][j].visible = false;
        placar += 10;
        --totalBolas;
        
        //Tocar um som de soco aleatório.
        if(totalBolas>0)
        {
          int index = int(random(3));
          sons[index].play();
          sons[index].rewind();
        }
        //Caso a bola destruída for a última, tocar um som de explosão.
        else
        {
           sons[7].play();
           sons[7].rewind(); 
        }
      }
    }
  }

  //Se o numero de bolas na tela acabar, encerrar jogo com vitória.
  boolean v = false;
  for (int i = 0; i < maxLinhas; i++) {
    for (int j = 0; j < maxColunas; j++) {
      if(blocos[i][j].visible)
       { 
         v=true;
         break;
       }
    }
  }
  if(!v)
    finalizarJogo(true);
}

//Inicializando o programa.
void setup() { 
  //Setando o ícone da janela.
  ImageIcon titlebaricon = new ImageIcon(loadBytes("icon.png"));
  frame.setIconImage(titlebaricon.getImage());
  //Tamanho da tela. 
  size(resolucao_x, resolucao_y);
  
  //Omitindo bordas das figuras.
  noStroke();
  
  //Inicializando áudio. (Arquivos de http://www.soundbible.com e http://www.freesound.org)
  minim = new Minim(this);
  sons = new AudioPlayer[9];
  sons[0] = minim.loadFile("soco1.mp3");  //Colisão com bloco
  sons[1] = minim.loadFile("soco2.mp3");  //Colisão com bloco
  sons[2] = minim.loadFile("soco3.mp3");  //Colisão com bloco
  sons[3] = minim.loadFile("wall.mp3");   //Colisao com a parede
  sons[4] = minim.loadFile("jump.wav");   //Colisao com a plataforma
  sons[5] = minim.loadFile("fall.wav");   //Quando a bola sai da tela
  sons[6] = minim.loadFile("gameover.wav");  //Quando o jogo termina em derrota
  sons[7] = minim.loadFile("boom.mp3");   //Colisão com o último bloco restante
  sons[8] = minim.loadFile("win.wav");    //Quando o jogo termina em vitória

  //Inicializando fonte. (http://www.dafont.com/pt/04b-19.font)
  PFont font = loadFont("04b19-48.vlw");
  textFont(font);
  
  //Carregando texturas.
  vitoria = loadImage("feliz.png");
  derrota = loadImage("triste.png");
  heart = loadImage("heart.png");

  //Criando e posicionando blocos.
  blocos = new Bloco[maxLinhas][maxColunas];
  for (int i = 1; i < maxLinhas+1; i++) {
    for (int j = 1; j < maxColunas+1; j++) {
      blocos[i-1][j-1] = new Bloco(j*22+25, i*12+110);
    }
  }
  //Criando plataforma e bola.
  plataforma = new Plataforma();
  bola = new Bola();
  
  //Inicializando variáveis.
  inicializarJogo();
}

//Enquanto não existir vitória ou derrota, o jogo desenha a tela de jogo.
//Quando não está pausado, ele chama o método update que atualiza a lógica interna do jogo.
//Caso contrário, ele desenha o texto de ajuda.
void draw() {

  if (mostrarVitoria)
    drawVitoria();
  else if (mostrarDerrota)
    drawDerrota();
  else {
    drawJogo();
    if (!pausado)
      update();
    else
      drawAjuda();
  }
}

//Métodos de input
void keyPressed()
{
  if (key == CODED)
  {
    //Mover a plataforma com as setas.
    if (keyCode == RIGHT)
      plataforma.setDirecao(plataforma.esq, true, false);
    else if (keyCode == LEFT)
      plataforma.setDirecao(true, plataforma.dir, false);
  }
  //Se apertar espaço.
  else if (key == 32)
  {
    //Se estiver na tela de derrota ou vitória, reinicie o jogo.
    if(mostrarDerrota || mostrarVitoria)
      inicializarJogo();
    //Se estiver dentro do jogo.
    else
    {
      //Se a bola estiver morta, revivê-la.
      if(bola.morta)
        bola.morta = false;
      //Se não, pausar/despausar o jogo.
      else
        pausado = !pausado;
    }  
  }
  //Trapaça
  else if(key == 'v' || key == 'V')
    if(vidas < 99)
      ++vidas;
}
//Parar direcionamento quando a tecla é solta.
void keyReleased()
{
  if (key == CODED)
  {
    if (keyCode == RIGHT)
      plataforma.setDirecao(plataforma.esq, false, false);
    else if (keyCode == LEFT)
      plataforma.setDirecao(false, plataforma.dir, false);
  }
}
//Pegar o direcionamento do mouse em X e aplicá-lo à plataforma.
void mouseMoved()
{
  boolean esq=false, dir=false;
  int direcao = mouseX - pmouseX;

  if (direcao > 0)
  {
    dir = true;
    esq = false;
  } else if (direcao < 0)
  {
    esq = true;
    dir = false;
  }
  plataforma.setDirecao(esq, dir, true);
}

