smallsmallvalue = 0.1;
// util functions
function valueor(value,orvalue) = is_undef(value) ? orvalue : value; 
function valueor_cap(value, cap) = is_undef(value) ? cap : (value>cap ? cap : value);

// Switch type specific definitions 
MxSwitchType = 0;

MxSwitchHoleHolder = [14,14,1.7];
MxSwitchHoleExt = [15,15,5-1.7];
MxSwitchPinRadius = 1.5;
MxSwitchPinSize = 3;
MxSwitchHoleHeight = MxSwitchHoleHolder[2]+MxSwitchHoleExt[2];
MxSwitchHeight = 10 ;

// kb specific util functions

function key_holder_clearence(switchtype) = 
    switchtype == MxSwitchType ? MxSwitchHoleExt 
    : MxSwitchHoleExt;

function key_holder_height(switchtype) = switchtype == 1 ? MxSwitchHoleHeight 
    : MxSwitchHoleHeight;

// cap wall thickness
function wallt_normalize(wallt,capsize, keyholderclearence) = valueor_cap(wallt, (capsize - keyholderclearence)/2);

// matrix functions
// get rown of keyswitch in same row different column
function translateRownToCol(rown, coln, colhome, coldefhome, homeval) = rown + valueor(colhome[coln],coldefhome) - homeval;
function getKey(matrix, rows, cols, rown, coln) = coln < 0 || coln >= cols || rown < 0 || rown >= rows ? true : (!valueor(matrix[rown][coln],true));


// walls modules

module generateKeyHolderCornerWalls(capsize, wallh, xw, yw, lf, rf, rb, lb){
    xt = capsize[0]-xw;
    yt = capsize[1]-yw;
    size = [xw,yw,wallh];
    translate([0,0,-wallh]){
        if(valueor(lf,false)){
            cube(size);
        }
        if(valueor(rf,false)){
            translate([xt,0,0])
            cube(size);
        }
        if(valueor(rb,false)){
            translate([xt,yt,0])
            cube(size);
        }
        if(valueor(lb,false)){
            translate([0,yt,0])
            cube(size);
        }
    }
}
module generateKeyHolderFlatWalls(capsize,  wallh, xw, yw, rwall, lwall, fwall, bwall){
    xt = capsize[0]-xw;
    yt = capsize[1]-yw;
    translate([0,0,-wallh]) {
        if(valueor(rwall,false)){
            translate([xt,0,0])
            cube([xw,capsize[1],wallh]);
        }
        if(valueor(lwall,false)){
            cube([xw,capsize[1],wallh]);
        }
        if(valueor(fwall,false)){
            cube([capsize[0],yw,wallh]);
        }
        if(valueor(bwall,false)){
            translate([0,yt,0])
            cube([capsize[0],yw,wallh]);
        }
    }
}

module __generateKeyHolderWalls(capsize, keyholderclearence, wallh, wallt, rwall, lwall, fwall, bwall, lfwall, rfwall, rbwall, lbwall){
    xw = wallt_normalize(wallt, capsize[0], keyholderclearence[0]); 
    yw = wallt_normalize(wallt, capsize[1], keyholderclearence[1]);
    generateKeyHolderFlatWalls(capsize, wallh, xw, yw, rwall, lwall, fwall, bwall);
    generateKeyHolderCornerWalls(capsize, wallh, xw, yw, lfwall, rfwall, rbwall, lbwall);
}
module generateKeyHolderWalls(switchtype, capsize, wallh, wallt, rwall, lwall, fwall, bwall, lfwall, rfwall, rbwall, lbwall){
    __generateKeyHolderWalls(capsize = capsize, keyholderclearence = key_holder_clearence(switchtype)
    , wallh = wallh, wallt = wallt, rwall = rwall, lwall = lwall, fwall = fwall, bwall = bwall, lfwall = lfwall, rfwall = rfwall, rbwall = rbwall, lbwall = lbwall);
}

module KeyHolderWallAdapterPart(wallh, xw, yw) {
    translate([0,0,-wallh])
    if(!is_undef(xw)){
        cube([xw,smallsmallvalue, wallh]);
    }
    if(!is_undef(yw)){
        cube([smallsmallvalue,yw, wallh]);
    }
}
module __generateKeyHolderWallAdapter(capsize, keyholderclearence, wallh, wallt, fl,fr,rf,rb,br,bl,lb,lf){
    xw = wallt_normalize(wallt, capsize[0], keyholderclearence[0]); 
    yw = wallt_normalize(wallt, capsize[1], keyholderclearence[1]);
    fbxt = capsize[0]-xw; // front-to-back x translate
    fbyt = capsize[1]-smallsmallvalue; // front-to-back y translate
    lrxt = capsize[0]-smallsmallvalue; // left-to-right x translate
    lryt = capsize[1]-yw; // left-to-right y translate
    //front
    {
        if(fl) KeyHolderWallAdapterPart(wallh, xw = xw);
        if(fr) translate([fbxt,0,0]) KeyHolderWallAdapterPart(wallh, xw = xw);
    }
    //back
    translate([0,fbyt,0]){
        if(bl) KeyHolderWallAdapterPart(wallh, xw = xw);
        if(br) translate([fbxt,0,0]) KeyHolderWallAdapterPart(wallh, xw = xw);
    }
    // left
    {
        if(lf) KeyHolderWallAdapterPart(wallh, yw = yw);
        if(lb) translate([0,lryt,0]) KeyHolderWallAdapterPart(wallh, yw = yw);
    }
    // right
    translate([lrxt, 0, 0]){
        if(rf) KeyHolderWallAdapterPart(wallh, yw = yw);
        if(rb) translate([0,lryt,0]) KeyHolderWallAdapterPart(wallh, yw = yw);
    }
}
module generateKeyHolderWallAdapter(switchtype, wallh, wallt, fl,fr,rf,rb,br,bl,lb,lf){
    __generateKeyHolderWallAdapter(capsize = capsize, 
    keyholderclearence = key_holder_clearence(switchtype) 
    , wallh = wallh, wallt = wallt, fl = fl, fr = fr, rf = rf, rb = rb, br = br, bl = bl, lb = lb, lf = lf);
}

// mx modules
module generateMxSwitchPin() {
    difference(){
        rotate([-90,0,0])
            cylinder(r=MxSwitchPinRadius,h=MxSwitchPinSize,$fn=20);
        translate([-MxSwitchPinRadius,0,-MxSwitchPinRadius]) cube([MxSwitchPinRadius,MxSwitchPinSize,MxSwitchPinRadius*2]);
    }
}
module generateMxKeyHolder(capsize, wallh, wallt, rwall, lwall, fwall, bwall, lfwall, rfwall, rbwall, lbwall){
    union(){
        translate([0,0,-MxSwitchHoleHeight])
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

// keyHolder modules
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

module generateKeyHolder(switchtype, capsize, wallh, wallt, rwall, lwall, fwall, bwall, lfwall, rfwall, rbwall, lbwall){
    swttemp = valueor(switchtype, 0);
    swt = swttemp > 1 || swttemp < 0 ? 0 : swttemp;
    if(swt == MxSwitchType) generateMxKeyHolder(capsize, wallh, wallt, rwall, lwall, fwall, bwall, lfwall, rfwall, rbwall, lbwall);

    generateKeyHolderWalls(switchtype, capsize 
        , wallh, wallt, rwall, lwall, fwall, bwall, lfwall, rfwall, rbwall, lbwall);
}
module keyHolderAdapterPart(height) cube([smallsmallvalue, smallsmallvalue, height]);
module generateKeyHolderAdapter(switchtype, capsize, fl, fr, br, bl){
    height = key_holder_height(switchtype);
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

// Matrix Column modules
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

module generateSwitchMatrixColAdapter(switchtype, capsize, wallh, wallt, rows, cols, coln,matrix, pad, defpad,rrot,rdefrot, colsrot, colsdefrot, sdefrot, colhome, coldefhome){
    if(coln > 0){
        homeval = valueor(colhome[coln],coldefhome);
        lhomeval = valueor(colhome[coln-1],coldefhome);
        for(rown=[0:1:rows-1]) {
            if(valueor(matrix[rown][coln],true)) {
                lcoln = coln-1;
                lrown = translateRownToCol(rown, lcoln, colhome, coldefhome, homeval);
                lwall = getKey(matrix, rows, cols, lrown, lcoln);

                lfcoln = coln-1;
                lfrown = translateRownToCol(rown-1, lfcoln, colhome, coldefhome, homeval);

                lfwall = getKey(matrix, rows, cols, lfrown, lfcoln);

                fcoln = coln;
                frown = rown-1;
                fwall = getKey(matrix, rows, cols, frown, fcoln);

                if(!lwall){
                    // surface connector
                    hull(){
                        translateKeyHolder(capsize, lhomeval, lcoln, colsrot, colsdefrot, sdefrot, true) translateKeyHolder(capsize, lrown, lcoln, colsrot, colsdefrot, sdefrot)
                            generateKeyHolderAdapter(switchtype, capsize, true, false, false, true);
                        translateSwitchMatrixCol(capsize, coln, pad, defpad, rrot, rdefrot,true) translateSwitchMatrixCol(capsize, lcoln, pad, defpad, rrot, rdefrot)
                            translateKeyHolder(capsize, homeval, coln, colsrot, colsdefrot, sdefrot, true) translateKeyHolder(capsize, rown, coln, colsrot, colsdefrot, sdefrot)
                                generateKeyHolderAdapter(switchtype, capsize, false, true, true, false);
                    }
                }
                if(!lwall && !lfwall && !fwall){
                    // surface corner connector
                    hull(){
                        union(){
                        translateKeyHolder(capsize, lhomeval, lcoln, colsrot, colsdefrot, sdefrot, true) translateKeyHolder(capsize, lrown, lcoln, colsrot, colsdefrot, sdefrot)
                            generateKeyHolderAdapter(switchtype, capsize, true, false, false, false);
                        translateKeyHolder(capsize, lhomeval, lfcoln, colsrot, colsdefrot, sdefrot, true) translateKeyHolder(capsize, lfrown, lfcoln, colsrot, colsdefrot, sdefrot)
                            generateKeyHolderAdapter(switchtype, capsize, false, false, false, true);
                            };

                        translateSwitchMatrixCol(capsize, coln, pad, defpad, rrot, rdefrot,true) translateSwitchMatrixCol(capsize, lcoln, pad, defpad, rrot, rdefrot) 
                        union(){
                            translateKeyHolder(capsize, homeval, coln, colsrot, colsdefrot, sdefrot, true) translateKeyHolder(capsize, rown, coln, colsrot, colsdefrot, sdefrot)
                                generateKeyHolderAdapter(switchtype, capsize, false, true, false, false);
                            translateKeyHolder(capsize, homeval, fcoln, colsrot, colsdefrot, sdefrot, true) translateKeyHolder(capsize, frown, fcoln, colsrot, colsdefrot, sdefrot)
                                generateKeyHolderAdapter(switchtype, capsize, false, false, true, false);
                        }
                    }
                }
            }
        }
    }
}

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

            lfwall = !(lwall || fwall) && getKey(matrix, rows, cols, lrown-1, lcoln);
            rfwall = !(rwall || fwall) && getKey(matrix, rows, cols, rrown-1, rcoln);
            rbwall = !(rwall || bwall) && getKey(matrix, rows, cols, rrown+1, rcoln);
            lbwall = !(lwall || bwall) && getKey(matrix, rows, cols, lrown+1, lcoln);

            translateKeyHolder(capsize, rown, coln, colsrot, colsdefrot, sdefrot)
                generateKeyHolder(switchtype, capsize, wallh,wallt,rwall,lwall,fwall,bwall, lfwall, rfwall, rbwall, lbwall);
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

// generate whole matrix with walls
module generateSwitchMatrix(switchtype, capsize,wallh,wallt, rows,cols, matrix, homecol, pad, defpad,rrot,rdefrot, colsrot, colsdefrot, sdefrot, colhome, coldefhome){
    homecolval = valueor(homecol, 0);
    translateSwitchMatrixCol(capsize, homecolval, pad, defpad, rrot, rdefrot, true)
    for(coln=[0:1:cols-1]){
        translateSwitchMatrixCol(capsize, coln,pad,defpad,rrot,rdefrot) union(){
            if(coln != 0){
                generateSwitchMatrixColAdapter(switchtype, capsize, wallh, wallt, rows, cols, coln,matrix,pad, defpad,rrot,rdefrot, colsrot, colsdefrot, sdefrot, colhome, coldefhome);
            }
            generateSwitchMatrixCol(switchtype, capsize, wallh, wallt, rows, cols, coln, matrix, colsrot, colsdefrot, sdefrot, colhome, coldefhome);
        }
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
defpad = [2,5,10],
rrot = [],
rdefrot = [0,-10,0],
colsrot = [],
colsdefrot = [],
sdefrot = [20,0,0],
colhome = [0,1,2,3,1],
coldefhome = 2
);
