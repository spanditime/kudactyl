MxSwitchHoleHolder = [14,14,1.7];
MxSwitchHoleExt = [15,15,5-1.7];
MxSwitchPinRadius = 1.5;
MxSwitchPinSize = 3;
MxSwitchHoleHeight = MxSwitchHoleHolder[2]+MxSwitchHoleExt[2];
MxSwitchHeight = 10 ;

function valueor(value,orvalue) = is_undef(value) ? orvalue : value; 
module generateMxSwitchPin() {
    difference(){
        rotate([-90,0,0])
            cylinder(r=MxSwitchPinRadius,h=MxSwitchPinSize,$fn=20);
        translate([-MxSwitchPinRadius,0,-MxSwitchPinRadius]) cube([MxSwitchPinRadius,MxSwitchPinSize,MxSwitchPinRadius*2]);
    }
}
MxSwitchType = 0;
module generateMxKeyHolder(capsize, wallh, wallt, rwall,lwall, fwall, bwall){
    translate([0,0,-valueor(wallh,0)-MxSwitchHoleHeight])
    union(){
        rwt = (capsize[0]-MxSwitchHoleExt[0])/2;
        rw = is_undef(wallt) ? rwt : (wallt>rwt ? rwt : wallt);
        rt = capsize[0]-rw;
        lwt = (capsize[1]-MxSwitchHoleExt[1])/2;
        lw = is_undef(wallt) ? lwt : (wallt>lwt ? lwt : wallt);
        lt = capsize[1]-lw;
        if(valueor(rwall,false)){
            translate([rt,0,0])
            cube([rw,capsize[1],wallh]);
        }
        if(valueor(lwall,false)){
            cube([rw,capsize[1],wallh]);
        }
        if(valueor(fwall,false)){
            cube([capsize[0],lw,wallh]);
        }
        if(valueor(bwall,false)){
            translate([0,lt,0])
            cube([capsize[0],lw,wallh]);
        }

        translate([0,0,wallh])
        union(){
        // switch holder
            difference(){
                union(){
                    cube([capsize[0],capsize[1],MxSwitchHoleHeight]);
                }
                union(){
                    translate([(capsize[0]-MxSwitchHoleExt[0])/2, (capsize[1]-MxSwitchHoleExt[1])/2, 0])
                        cube(MxSwitchHoleExt);
                    translate([(capsize[0]-MxSwitchHoleHolder[0])/2,(capsize[1]-MxSwitchHoleHolder[1])/2,MxSwitchHoleExt[2]]) cube(MxSwitchHoleHolder);
                }
            }
            // switch holder pins
            union(){
                // todo: calculate how much up do we need to shift the Pin, for now a whole radius(thats approximatelly right)
                translate([(capsize[0]-MxSwitchHoleExt[0])/2,(capsize[1]-MxSwitchPinSize)/2,MxSwitchPinRadius])
                    generateMxSwitchPin();
                translate([(capsize[0]-MxSwitchHoleExt[0])/2+MxSwitchHoleExt[0],(capsize[1]-MxSwitchPinSize)/2,MxSwitchPinRadius])
                    rotate([0,180,0])
                    generateMxSwitchPin();
            }
        }
    }
}
module generateKeyHolder(switchtype, capsize, wallh, wallt, rwall, lwall, fwall, bwall){
    swttemp = valueor(switchtype, 0);
    swt = swttemp > 1 || swttemp < 0 ? 0 : swttemp;
    if(swt == MxSwitchType) generateMxKeyHolder(capsize, wallh, wallt, rwall, lwall, fwall, bwall);
}
smallsmallvalue = 0.00001;
module keyHolderAdapterPart(height) cube([smallsmallvalue, smallsmallvalue, height]);
module generateKeyHolderAdapter(switchtype, capsize, fl, fr, br, bl){
    height = switchtype == 1 ? MxSwitchHoleHeight 
    : MxSwitchHoleHeight;
    translate([0,0,-height])
    union(){
        if(fl){
            keyHolderAdapterPart(height);
        }
        if(fr){
            translate([capsize[0]-smallsmallvalue,0,0])
            keyHolderAdapterPart(height);
        }
        if(br){
            translate([capsize[0]-smallsmallvalue,capsize[1]-smallsmallvalue,0])
            keyHolderAdapterPart(height);
        }
        if(bl){
            translate([0,capsize[1]-smallsmallvalue,0])
            keyHolderAdapterPart(height);
        }
    }
}

module __translateSwitchMatrixCol(capsize, i,coln,pad,defpad,rrot,rdefrot, reverse){
    if(valueor(reverse,false)){
        if(coln>i){
            p = valueor(pad[coln-1], defpad);
            r = valueor(rrot[coln-1], rdefrot);
            rotate(-r) translate(-p) 
            translate([-capsize[0],0,0])
            __translateSwitchMatrixCol(capsize, i, coln-1, pad, defpad, rrot, rdefrot, reverse) 
            children();
        }else{
            children();
        }
    }
    else
    {
        if(i < coln){
            p = valueor(pad[i], defpad);
            r = valueor(rrot[i], rdefrot);
            translate([capsize[0],0,0]) 
            translate(p) rotate(r) __translateSwitchMatrixCol(capsize, i+1,coln,pad,defpad,rrot,rdefrot,reverse) children();
        }else{
            children();
        }
    }
}
module translateSwitchMatrixCol(capsize, coln,pad,defpad,rrot,rdefrot, reverse){
    __translateSwitchMatrixCol(capsize, 0,coln,pad,defpad,rrot,rdefrot, reverse) children();
}

module __translateKeyHolder(capsize, i, rown, coln, colsrot, colsdefrot, sdefrot, reverse) {
    if(reverse){
        if(rown>i){
            colrot = valueor(colsrot[coln], colsdefrot);
            rot = valueor(colrot[rown-1], sdefrot);
            rotate(-rot) /*pad*/ 
            translate([0,-capsize[1],0])
            __translateKeyHolder(capsize, i, rown-1, coln, colsrot, colsdefrot, sdefrot, reverse) children();
        }else{
            children();
        }
    }
    else
    {
        if(i < rown){
            colrot = valueor(colsrot[coln], colsdefrot);
            rot = valueor(colrot[i-1], sdefrot);
            translate([0,capsize[1],0])
            /*pad*/ rotate(rot)
            __translateKeyHolder(capsize, i+1, rown, coln, colsrot, colsdefrot, sdefrot, reverse) children();
        }else{
            children();
        }
    }
}
module translateKeyHolder(capsize, rown, coln, colsrot, colsdefrot, sdefrot, reverse){
    __translateKeyHolder(capsize, 0, rown, coln, colsrot, colsdefrot, sdefrot, reverse) children();
}

function translateRownToCol(rown, coln, colhome, coldefhome, homeval) = rown + valueor(colhome[coln],coldefhome) - homeval;
function getKey(matrix, rows, cols, rown, coln) = coln < 0 || coln >= cols || rown < 0 || rown >= rows ? true : (!valueor(matrix[rown][coln],true));

module generateSwitchMatrixCol(switchtype, capsize, wallh, wallt, rows, cols, coln,matrix, colsrot, colsdefrot, sdefrot, colhome, coldefhome){
    homeval = valueor(colhome[coln],coldefhome);
    translateKeyHolder(capsize, homeval, coln, colsrot, colsdefrot, sdefrot, true)
    for(rown=[0:1:rows-1]) {
        if(valueor(matrix[rown][coln],true)) {
            rcoln = coln+1;
            lcoln = coln-1;
            rrown = translateRownToCol(rown, rcoln, colhome, coldefhome, homeval);
            lrown = translateRownToCol(rown, lcoln, colhome, coldefhome, homeval);
            brown = rown+1;
            frown = rown-1;
            rwall = getKey(matrix, rows, cols, rrown, rcoln);
            lwall = getKey(matrix, rows, cols, lrown, lcoln);
            fwall = getKey(matrix, rows, cols, frown, coln);
            bwall = getKey(matrix, rows, cols, brown, coln);
            translateKeyHolder(capsize, rown, coln, colsrot, colsdefrot, sdefrot)
                generateKeyHolder(switchtype, capsize, wallh,wallt,rwall,lwall,fwall,bwall);
        }
        if(rown > 0 && valueor(matrix[rown][coln], true) && valueor(matrix[rown-1][coln],true)){
            hull(){
                translateKeyHolder(capsize, rown, coln, colsrot, colsdefrot, sdefrot)
                    generateKeyHolderAdapter(switchtype, capsize, true, true, false, false);
                translateKeyHolder(capsize, rown-1, coln, colsrot, colsdefrot, sdefrot)
                    generateKeyHolderAdapter(switchtype, capsize, false, false, true, true);
            }
        }
    }
}
// generate whole matrix with walls where needed
module generateSwitchMatrix(switchtype, capsize,wallh,wallt, rows,cols, matrix, homecol, pad, defpad,rrot,rdefrot, colsrot, colsdefrot, sdefrot, colhome, coldefhome){
    homecolval = valueor(homecol, 0);
    translateSwitchMatrixCol(capsize, homecolval, pad, defpad, rrot, rdefrot, true)
    for(coln=[0:1:cols-1]){
        translateSwitchMatrixCol(capsize, coln,pad,defpad,rrot,rdefrot)
        generateSwitchMatrixCol(switchtype, capsize, wallh, wallt, rows, cols, coln, matrix, colsrot, colsdefrot, sdefrot, colhome, coldefhome);
    }
}

generateSwitchMatrix(
switchtype=MxSwitchType, 
capsize = [20,20,20],
wallh = 20,
wallt = 20,
rows = 4,
cols = 5,
matrix = [
  [true,true],
  [true,true, false],
],
homecol = 2,
pad = [],
defpad = [2,0,0],
rrot = [],
rdefrot = [0,-10,0],
colsrot = [],
colsdefrot = [],
sdefrot = [20,0,0],
colhome = [0,1,2,3,1],
coldefhome = 2
);
