/// @description GridFloor Create
#region floor
gridFloor = new RenderComponent(id,true,false);
gridFloor.renderMode = pr_linelist;
gridFloor.renderTexture = -1;
gridFloor.customShader = NO_SHADER;

var vb = vertex_create_buffer()
vertex_begin(vb,global.VERTEX_FORMAT)
var gridSpace = 16;
var gridIntervals = 8;


var minD = gridSpace*-gridIntervals
var maxD = gridSpace*gridIntervals
var gridCol = $181818
var axisLine = $444444;

for(var i = -gridIntervals; i <= gridIntervals; i++) {
	var col = gridCol
	if !(abs(i) % 2) {col = axisLine}
	
	if(i == 0) {col = c_lime}
	define_line(vb,[gridSpace*i,minD,0],[gridSpace*i,maxD,0],col,1)	
	if(i == 0) {col = c_red}
	define_line(vb,[minD,gridSpace*i,0],[maxD,gridSpace*i,0],col,1)	
	}
	
var arrowdepth = 2;

//x axis
define_line(vb,[gridSpace,0,0],[gridSpace-arrowdepth,-1,0],c_red,1)	
define_line(vb,[gridSpace,0,0],[gridSpace-arrowdepth,1,0],c_red,1)	

var letterx = gridSpace-1;
var lettery = -3
define_line(vb,[letterx-1,lettery-1,0],[letterx+1,lettery+1,0],c_red,1)	
define_line(vb,[letterx-1,lettery+1,0],[letterx+1,lettery-1,0],c_red,1)	

//y axis
define_line(vb,[0,gridSpace,0],[1,gridSpace-arrowdepth,0],c_lime,1)	
define_line(vb,[0,gridSpace,0],[-1,gridSpace-arrowdepth,0],c_lime,1)	

var letterx = -3
var lettery = gridSpace-1;
define_line(vb,[letterx-1,lettery+1,0],[letterx,lettery,0],c_lime,1)	
define_line(vb,[letterx+1,lettery+1,0],[letterx,lettery,0],c_lime,1)	
define_line(vb,[letterx,lettery,0],[letterx,lettery-1,0],c_lime,1)	


//z axis
//define_line(vb,[0,0,-64],[0,0,64],c_blue,1)	
//define_line(vb,[0,0,gridSpace],[0,1,gridSpace-arrowdepth],c_blue,1)	
//define_line(vb,[0,0,gridSpace],[0,-1,gridSpace-arrowdepth],c_blue,1)	
	


vertex_end(vb)
vertex_freeze(vb);
gridFloor.renderBuffer = vb;
#endregion