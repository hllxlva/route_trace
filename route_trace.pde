boolean flag, L, R, auto;
float easing = 0.05;
int[][] data;
int[] initial_value = {100,100};
float[] now_pos = new float [2];
float min_m_dist;
float pre_min_m_dist = 1000;
int min_m_dist_num;
float[] v = new float [2];
float[] v_t = new float [2];
float[] v_n = new float [2];
float vx,vy,vx_t,vy_t,vx_n,vy_n;//接線方向と法線方向の速度
float e;

void setup(){
  size(2500,1200);
  String[] stuff = loadStrings("right_angle.txt");  // 文字列型の配列として，データを読み込み(stuff[0]が1行目の文字列)
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
}

void draw(){
  fill(0, 5);
  rect(0, 0, 2500, 1200);
  fill(255);
  //取得したデータを描画
  for (int i = 0; i < data.length; i++) {  //data.length で，配列 data の行数が得られる
    if (data[i].length==2) {//data[i].length で，配列 data の列数が得られる//x,y の２項目があれば
      ellipse(data[i][0], data[i][1], 3, 3);
    }
  }
  
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
    v_t[0] = 0;
    v_t[1] = 0;
    //法線方向の偏差
    e = 0;
  }else{
    //接線方向の速度
    v_t[0] = data[min_m_dist_num + 1][0] - data[min_m_dist_num][0];
    v_t[1] = data[min_m_dist_num + 1][1] - data[min_m_dist_num][1];
    //法線方向の偏差
    e = sqrt(sq((data[min_m_dist_num][1] - now_pos[1])*(v_t[0])+(now_pos[0] - data[min_m_dist_num][0])*(v_t[1]))/(sq(v_t[0])+sq(v_t[1])));
  }
  //法線方向の速度
  v_n[0] = data[min_m_dist_num][0] - now_pos[0];
  v_n[1] = data[min_m_dist_num][1] - now_pos[1];
  v[0] = v_t[0]*0.85 + v_n[0]*0.15;
  v[1] = v_t[1]*0.85 + v_n[1]*0.15;
  float R = sq(v[0]) + sq(v[1]);
  if(R>sq(5)){//最高速度
    v[0] = 5*v[0]/sqrt(R);
    v[1] = 5*v[1]/sqrt(R);
  }
  
  
  if(L){
    now_pos[0] = now_pos[0] + v[0];
    now_pos[1] = now_pos[1] + v[1];
  }
  
  
  text(pre_min_m_dist,100,100);
  translate(now_pos[0],now_pos[1]);
  fill(255,0,0);
  ellipse(0,0,10,10);
  translate(-now_pos[0],-now_pos[1]);
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