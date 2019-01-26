ArrayList<statObj> stats=new ArrayList<statObj>();
tableForm[] tables=new tableForm[3];
File files;

PFont font;
int score=3;

void setup(){
  size(1300,800);
  tables[0]=new tableForm(10,height/5,width/2-20,height*2/5-10,color(180,180,255));
  tables[1]=new tableForm(10,height*3/5,width/2-20,height*2/5-10,color(255,180,180));
  tables[2]=new tableForm(width/2+5,height/5,width/2-20,height*4/5-10,color(235));
  
  font=createFont("data/NotoSansCJKkr-Regular.otf",35);
  textAlign(CENTER,CENTER);
  // catch last file
  StringList fileList=new StringList();
  files=new File(sketchPath()+"/data");
  for(int i=0;i<files.listFiles().length;i++){
    fileList.append(files.listFiles()[i].toString());
  }
  fileList.sort();
  // memoryGet
  println("loadFiles: "+fileList.get(fileList.size()-1));
  String[] rawData=loadStrings(fileList.get(fileList.size()-1));
  int dlength=rawData.length;
  ArrayList<String[]> data=new ArrayList<String[]>();
  for(int i=0;i<dlength;i++){
    String[] result=split(rawData[i],TAB);
    if(result.length<4){
      result=append(result,"false");
    }
    data.add(result);
  }
  for(int i=0;i<dlength;i++){
    stats.add(new statObj(data.get(i)[0],data.get(i)[1],data.get(i)[2],data.get(i)[3]));
  }
  textFont(font,18);
}

void draw(){
  background(40);
  for(int i=0;i<tables.length;i++){
    tables[i].display();
  }
  for(int i=0;i<stats.size();i++){
    if(stats.get(i).taken()){
      if(stats.get(i).isGet){
        score-=stats.get(i).value;
      }else{
        score+=stats.get(i).value;
      }
    }
    stats.get(i).display();
  }
  
  pushStyle();
    rectMode(CORNER);
    fill(90);
    rect(0,0,50,50);
  popStyle();
  
  pushStyle();
    textAlign(LEFT,CENTER);
    textSize(20+height/55);
    text("Points: "+score,10,10);
  popStyle();
  pushStyle();
    textSize(25+height/35);
    text("무척 급하게 만든 프로그램",width/2,50);
  popStyle();
}

void saveData(ArrayList<statObj> used){
  StringList result=new StringList();
  int ulength=used.size();
  for(int i=0;i<ulength;i++){
    result.append(used.get(i).name+TAB+used.get(i).value+TAB+used.get(i).prop+TAB+used.get(i).isGet);
  }
  saveStrings("data/stats_"+year()+nf(month(),2)+nf(day(),2)+".txt",result.array());
  exit();
}

class tableForm{
  PVector pos,size;
  FloatList getTotalWidth=new FloatList();
  //int contain=0;
  color bgColr;
  
  tableForm(int posX,int posY,int sizeX,int sizeY,color bgCol){
    pos=new PVector(posX,posY);  size=new PVector(sizeX,sizeY);
    bgColr=bgCol;
  }
  
  PVector getPos(float itemWidth,float tall){
    PVector result=new PVector(0,0);
    //contain++;
    if(getTotalWidth.size()>0&&
      getTotalWidth.get(getTotalWidth.size()-1)+itemWidth<size.x){
        getTotalWidth.add(getTotalWidth.size()-1,itemWidth);
    }else{
      getTotalWidth.append(itemWidth);
    }
    result.x=pos.x+getTotalWidth.get(getTotalWidth.size()-1)-itemWidth;
    float totalTmp=0;
    //for(int i=0;i<getTotalWidth.size();i++){
    //  totalTmp+=getTotalWidth.get(i);
    //}
    result.y=pos.y+tall*(getTotalWidth.size()-1);
    return result;
  }
  
  void display(){
    pushStyle();
      rectMode(CORNER);
      fill(bgColr);
      rect(pos.x,pos.y,size.x,size.y);
    popStyle();
  }
}

class statObj{
  PVector pos=new PVector(0,0),size;
  float fontSize=18;
  String name="";
  String prop="";
  int value=0;
  boolean isGet=false;
  int rowNum;
  
  statObj(String statName,String howMuch, String des,String choosen){
    prop=des;
    isGet=boolean(choosen);
    value=int(howMuch);  name=statName+" ("+value+")";
    size=new PVector(textWidth(name)+70,fontSize*3);
    //noStroke();
    stroke(255);
    textAlign(CENTER,CENTER);
    rectMode(CENTER);
    pos=positioning();
  }

  PVector positioning(){
    if(value>0&&!isGet){
      return tables[0].getPos(size.x,size.y);
    }else if(!isGet){
      return tables[1].getPos(size.x,size.y);
    }else{
      return tables[2].getPos(size.x,size.y);
    }
  }
  
  float[] pkgRowCalc(int num){
    float[] result={};
    for(int i=num-1;i>=0;i--){
      append(result,stats.get(i));
    }
    return result;
  }
  
  void display(){
    if(taken()){
      pos=positioning();
    }
    pushMatrix();
    translate(pos.x+size.x/2,pos.y+size.y/2);
      pushStyle();
      {
        float hoverCol=0;
        if(hover()){
          hoverCol=30;
        }else{
          hoverCol=0;
        }
        fill(100-value*11+hoverCol,50+hoverCol,100+value*11+hoverCol);
      }
        rect(0,0,size.x,size.y);
        fill(255);
        text(name,0,fontSize*-.2);
      popStyle();
    popMatrix();
    if(hover()){
      propBalloon();
    }
  }
  
  void propBalloon(){
    pushStyle();
    float textBoxWidth=200;
      textFont(font);
      textSize(fontSize);
      rectMode(CORNER);
      ellipseMode(CENTER);
      fill(255,255,0,200);
      stroke(255);
      strokeWeight(1);
      rect(map(mouseX,0,width,30,width-30),
            mouseY-fontSize*(2+floor(textWidth(prop)/textBoxWidth)),
            textBoxWidth*-1*(2*round(map(mouseX,0,width,0,1))-1)+8,
            -fontSize*2*(1+floor(textWidth(prop)/textBoxWidth)));
      fill(255);
      ellipse(mouseX,mouseY,10,10);
      fill(255,0,0);
      textAlign(LEFT,TOP);
      text(prop,map(mouseX,0,width,30,width-30)+10,
            mouseY-fontSize*(2+floor(textWidth(prop)/textBoxWidth))+5,
            textBoxWidth*-1*(2*round(map(mouseX,0,width,0,1))-1),
            -fontSize*2*(1+floor(textWidth(prop)/textBoxWidth)));
      line(mouseX,mouseY,map(mouseX,0,width,30,width-30),mouseY-fontSize*(2+floor(textWidth(prop)/textBoxWidth)));
    popStyle();
  }
  
  boolean taken(){
    if(hover()&&mousePressed){
      isGet=!isGet;
      pos=positioning();
      return true;
    }else{
      return false;
    }
  }
  
  boolean hover(){
    if(btwl(mouseX,pos.x,size.x)&&btwl(mouseY,pos.y,size.y)){
      return true;
    }else{
      return false;
    }
  }
}

boolean btwl(float get,float start,float leng){
  if(get>start&&get<start+leng){
    return true;
  }else{
    return false;
  }
}

void mouseClicked(){
  if(btwl(mouseX,0,50)&&btwl(mouseY,0,50)){
    saveData(stats);
  }
}
