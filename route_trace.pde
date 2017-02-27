boolean flag, L, R, PRE_R = true;//, auto;
float easing = 0.05;
int[][] data;
int[] initial_value = {0,0};
float[] now_pos = new float [3];
float min_m_dist;
float pre_min_m_dist = 1000;
int min_m_dist_num;
float[] pre_v =new float [2];
float[] v = new float [3];
float[] v_t = new float [2];
float[] v_n = new float [2];
float[] p_v = new float [2];
float[] d_v = new float [2];
float r;
float vx,vy,vx_t,vy_t,vx_n,vy_n;//接線方向と法線方向の速度
float e, pre_e, eq, pre_eq, pre_pos;//編差
float[] v_max = {10,10};//最高速度{並進, 回転}
float slow_stop = 1.0;
float slow = 20;//スローで何％まで落とすか
float pre_r;
float[][] C = {{100, 0}, //Censerの位置
               {0, 100}, 
               {-100, 0},
               {0, -100}};
float[][] Cr = new float[4][2];//Censerの極座標表示[0] = x,[1] = y
float[][] M = {{100, 100, 45}, //Mecanumの位置
               {-100, 100, 135}, 
               {-100, -100, 225},
               {100, -100, 315}};
float[][] Mr = new float[4][2];//Mecanuumの極座標表示[0] = x,[1] = y
float[][] Km = new float[4][2];//計算上の係数
float[][] V_rotation = new float[4][2];
float[][] V_translation = new float[4][2];
float[] V_resultant = new float[2];
float[] V_out = new float[4];

void setup(){
  size(2500,1200);
  String[] stuff = loadStrings("theta.txt");  // 文字列型の配列として，データを読み込み(stuff[0]が1行目の文字列)
  data = new int[stuff.length][];  // 行数は先に特定する必要がある
  for(int i=0; i<stuff.length;i++){
    data[i] = int(split(stuff[i],','));  // 各行の文字列データについて，カンマを区切りとして配列を作成し，整数型に変換したものを data とする
  }
  //noLoop(); // draw() でループしないようにする
  noStroke();
  for (int i = 0; i < 2; i++){
    now_pos[i] = initial_value[i];
  }
  background(0);
  for (int i = 0; i < 4; i++) {
     Cr[i][0] = sqrt(C[i][0]*C[i][0]+C[i][1]*C[i][1]);
     Cr[i][1] = i*PI/2;
  }
  //irankamo
  for (int i = 0; i < 4; i++) {
     Mr[i][0] = sqrt(M[i][0]*M[i][0]+M[i][1]*M[i][1]);
     Mr[i][1] = PI/4+i*PI/2;
  }
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 2; j++){
      Km[i][j] = M[i][j]/sq(Mr[i][0]);
    } 
  }
}

void draw(){
  //fill(0, 5);
  //rect(0, 0, 2500, 1200);//透明に
  background(0);
  stroke(255);
  fill(255);
  //取得したデータを描画
  for (int i = 0; i < data.length; i++) {  //data.length で，配列 data の行数が得られる
    if (data[i].length==3) {//data[i].length で，配列 data の列数が得られる//x,y の２項目があれば
      ellipse(data[i][0], data[i][1], 1, 1);
    }
  }
  noStroke();
  if(!L){
    float targetX = mouseX;
    float targetY = mouseY;
    now_pos[0] = now_pos[0] + (targetX - now_pos[0]) * easing;
    now_pos[1] = now_pos[1] + (targetY - now_pos[1]) * easing;
  }
  
  for(int i = 0; i < data.length; i++){//マンハッタン距離最小値
    min_m_dist = sq(now_pos[0]-data[i][0])+sq(now_pos[1]-data[i][1]);
    if(flag){
      pre_min_m_dist = min_m_dist;
      flag = false;
    }
    if(pre_min_m_dist >= min_m_dist){
      pre_min_m_dist = min_m_dist;
      min_m_dist_num = i;
    }
  }
  flag = true;
  if(min_m_dist_num == data.length - 1){//最後まで行ったら速度0に
    //接線方向の速度
    v_t[0] = data[min_m_dist_num][0] - now_pos[0];
    v_t[1] = data[min_m_dist_num][1] - now_pos[1];
    r = sqrt(sq(v_t[0])+sq(v_t[1]));
    if(PRE_R){
      pre_r = r;
      if(pre_r < 1)pre_r = 1;
      fill(255);
      rect(0,0,100,100);
      PRE_R = false;
    }
    v_t[0] = v_t[0]/pre_r;
    v_t[1] = v_t[1]/pre_r;
    //法線方向の偏差
    e = 0;
    p_v[0] = 0;
    p_v[1] = 0;
    //d_v[0] = 0;//-----------------------------------------------------------------
    //d_v[1] = 0;//------------------------------------------------------------------
  }else{
    PRE_R = true;
    //接線方向の速度
    v_t[0] = data[min_m_dist_num + 1][0] - data[min_m_dist_num][0];
    v_t[1] = data[min_m_dist_num + 1][1] - data[min_m_dist_num][1];
    r = sqrt(sq(v_t[0])+sq(v_t[1]));
    v_t[0] = v_t[0]/r;
    v_t[1] = v_t[1]/r;
    //法線方向の偏差
    pre_e = e;
    e = sqrt(sq((data[min_m_dist_num][1] - now_pos[1])*(v_t[0])+(now_pos[0] - data[min_m_dist_num][0])*(v_t[1]))/(sq(v_t[0])+sq(v_t[1])));
    //線のどちら側にあるかを調べる
    if(v_t[0]*(data[min_m_dist_num][1] - now_pos[1])+v_t[1]*(now_pos[0] - data[min_m_dist_num][0]) > 0){
      e = -e;
    }
    //法線方向の比例制御
    p_v[0] = e * +v_t[1]/r;
    p_v[1] = e * -v_t[0]/r;
    //法線方向の微分制御
    //d_v[0] = (pre_e - e) * +v_t[1]/r;//--------------------------------------------------
    //d_v[1] = (pre_e - e) * -v_t[0]/r;//--------------------------------------------------
  }
  //法線方向の速度使わないと決めた
  //v_n[0] = data[min_m_dist_num][0] - now_pos[0];
  //v_n[1] = data[min_m_dist_num][1] - now_pos[1];
  
  //スローストップ
  int slow_stop_count = data.length-1-min_m_dist_num;
  if(slow_stop_count <= 20){
    slow_stop = slow_stop_count/20.0*(1-slow/100) + slow/100;
    if(slow_stop > 1.0) slow_stop = 1.0;
  }else{
    slow_stop = 1.0;
  }
  
  //制御の係数を代入
  float Kt = 20/*20*/, Kp = 2/*5*/;//, Kd = 2;//2
  //速度=接線方向の速度+法線方向の偏差に比例した分近づく-偏差の変化率が大きすぎる分
  v[0] = v_t[0]*Kt*slow_stop + p_v[0]*Kp;// + d_v[0]*Kd;//------------------------------------
  v[1] = v_t[1]*Kt*slow_stop + p_v[1]*Kp;// + d_v[1]*Kd;//------------------------------------
  //速度を求めてその大きさの大きさを引く
  //float V = sq(v[0])+sq(v[1]);//二回目//
  //d_v[0] = V * +v_t[1]/r;//
  //d_v[1] = V * -v_t[0]/r;//
  //v[0] += d_v[0]*Kd;//
  //v[1] += d_v[1]*Kd;//
  
  float R = sq(v[0]) + sq(v[1]);
  if(R>sq(v_max[0])){//最高速度
    v[0] = v_max[0]*v[0]/sqrt(R);
    v[1] = v_max[0]*v[1]/sqrt(R);
  }
  
  //------------角度操作---------------------
  pre_eq = eq;
  eq = data[min_m_dist_num][2] - now_pos[2];
  float Cp = 0.1, Cd = 0.5;
  v[2] = eq * Cp + (now_pos[2] - pre_pos) * Cd;//v[2] = eq * Cp - (pre_pos - now_pos[2]) * Cd;
  if(v[2] > v_max[1])v[2] = v_max[1];
  if(v[2] < -v_max[1])v[2] = -v_max[1];
  pre_pos = now_pos[2];
  
  if(L){
    now_pos[0] = now_pos[0] + v[0];
    now_pos[1] = now_pos[1] + v[1];
    now_pos[2] = now_pos[2] + v[2];
  }
  
  //回転方向速度ベクトル
  for (int j = 0; j < 4; j++) {
    for (int i = 0; i < 2; i++){
      V_rotation[j][i] = (-1+2*i)*v[2]*M[j][1-1*i];
    }
  }
  //並進方向速度ベクトル
  for (int i = 0; i < 4; i++) {
    V_translation[i][0] =  v[0]*cos(now_pos[2]*PI/180)+v[1]*sin(now_pos[2]*PI/180);
    V_translation[i][1] = -v[0]*sin(now_pos[2]*PI/180)+v[1]*cos(now_pos[2]*PI/180);
  }
  //各メカナム出力
  for (int i = 0; i < 4; i++) {
    V_out[i] = -(v[2]*-Km[i][1]/*+v[0]ここにだけsinをかける*/)*sin((M[i][2])*PI/180)+(v[2]*Km[i][0]/*+v[1]*/)*cos((M[i][2])*PI/180);
  }
  
  text(v[2],100,100);
  text(V_translation[0][0],100,120);
  text(V_translation[0][1],100,140);
  text(V_rotation[0][1],100,160);
  
  //ロボット描画------------------------------------
  //fill(150);
  translate(now_pos[0],now_pos[1]);//ロボットの中心を(0, 0)に
  rotate(-now_pos[2]*PI/180);//ロボットの回転数分回転
  fill(0,255,0);
  for (int i = 0; i < 4; i++) {//各センサー部分
    rotate(-Cr[i][1]);//センサーの位置に
    translate(Cr[i][0],0);//移動する
    rect(-2,-5,4,10);//センサー描画
    translate(-Cr[i][0],0);
    rotate(Cr[i][1]);
    fill(150);
  }
  fill(255);
  for (int i = 0; i < 4; i++) {//各メカナム部分
    rotate(-Mr[i][1]);//メカナムの位置に
    translate(Mr[i][0],0);//移動する
    rect(-2,-5,4,10);//メカナム描画
    stroke(255,0,0);
    line(0,0,0,-100*V_out[i]);
    noStroke();
    translate(-Mr[i][0],0);
    rotate(Mr[i][1]);
  }
  fill(255,0,0);
  ellipse(0, 0, 10, 10);//中心点
  rotate(now_pos[2]*PI/180);
  translate(-now_pos[0],-now_pos[1]);
  //pointまでの線
  stroke(0,255,0);
  line(data[min_m_dist_num][0],data[min_m_dist_num][1],now_pos[0],now_pos[1]);
  noStroke();
}
void mousePressed(){
  switch (mouseButton) {
    case LEFT:
      L = true;
      break;
    case RIGHT:
      R = true;
      break;
  }
}
void mouseReleased(){
  switch (mouseButton) {
    case LEFT:
      L = false;
      break;
    case RIGHT:
      R = false;
      break;
  }
}