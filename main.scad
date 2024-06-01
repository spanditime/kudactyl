smallsmallvalue = 0.1;
// util functions
function valueor(value,orvalue) = is_undef(value) ? orvalue : value; 
function valueor_cap(value, cap) = is_undef(value) ? cap : (value>cap ? cap : value);
function valueor_lowcap(value, cap) = is_undef(value) ? cap : (value<cap ? cap : value);
function bti(boool) = boool ? 1 : 0;

// Switch type specific definitions 
MxSwitchType = 0;
MxHotswapSwitchType = 1;

// MX
MxSwitchHoleHolder = [14,14,1.6];
MxSwitchHoleExt = [15,15,5-1.6];
MxSwitchPinRadius = 1.1;
MxSwitchPinSize = 3;
MxSwitchHoleHeight = MxSwitchHoleHolder[2]+MxSwitchHoleExt[2];
MxSwitchHeight = 10 ;
MxSwitchMinWallh = 5;
MxCapsizeMin = [16,16,11];

// MX HOTSWAP 
MxHotswapPlateHeight = 1.5;
MxHotswapSwitchHoleHeight = MxSwitchHoleHeight+MxHotswapPlateHeight;
MxHotswapSwitchMinWallh = 5;
MxHotswapCapsizeMin = [17,16,11];

// kb specific util functions
function switchtype_or(switchtype) = 
switchtype == MxSwitchType || switchtype == MxHotswapSwitchType ? switchtype : MxSwitchType;
function switchtype_check(switchtype) = is_undef(switchtype) ? MxSwitchType : switchtype_or(switchtype);
function key_holder_clearence(switchtype) = 
    switchtype == MxSwitchType ? MxSwitchHoleExt 
    : switchtype == MxHotswapSwitchType ? MxSwitchHoleExt
    : MxSwitchHoleExt;

function key_holder_height(switchtype) = switchtype == MxSwitchType ? MxSwitchHoleHeight 
    : switchtype == MxHotswapSwitchType ? MxHotswapSwitchHoleHeight
    : MxSwitchHoleHeight;

function min_wallh(switchtype) = 
    switchtype == MxSwitchType ? MxSwitchMinWallh 
    : switchtype == MxHotswapSwitchType ? MxHotswapSwitchMinWallh
    : MxSwitchMinWallh;

function capsize_lowcap(capsize, mincapsize) = [
    valueor_lowcap(capsize[0], mincapsize[0]),
    valueor_lowcap(capsize[1], mincapsize[1]),
    valueor_lowcap(capsize[2], mincapsize[2])
];

function MX_capsize_normalize(capsize) = 
    capsize_lowcap(valueor(capsize,MxCapsizeMin),MxCapsizeMin);
function MXH_capsize_normalize(capsize) = 
    capsize_lowcap(valueor(capsize,MxHotswapCapsizeMin),MxHotswapCapsizeMin);

function capsize_normalize(switchtype, capsize) = 
    switchtype == MxSwitchType ? MX_capsize_normalize(capsize) :
    switchtype == MxHotswapSwitchType ? MXH_capsize_normalize(capsize) :
    MX_capsize_normalize(capsize);

// cap wall thickness
function wallt_normalize(wallt,capsize, keyholderclearence) = valueor_cap(wallt, (capsize - keyholderclearence)/2);
function wallh_normalize(switchtype, wallh) = valueor_lowcap(wallh, min_wallh(switchtype));

// matrix functions
// get rown of keyswitch in same row different column
function translateRownToCol(rown, coln, colhome, coldefhome, homeval) = rown + valueor(colhome[coln],coldefhome) - homeval;
function getKey(matrix, rows, cols, rown, coln) = coln < 0 || coln >= cols || rown < 0 || rown >= rows ? true : (!valueor(matrix[rown][coln],true));
function getRelativeKey(matrix, rows, cols, colhome, coldefhome, rown, coln, rowoff, coloff) = getKey(matrix, rows, cols, translateRownToCol(rown, coln+coloff, colhome, coldefhome, valueor(colhome[coln],coldefhome))+rowoff, coln+coloff);

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
module __generateKeyHolderWallPart(wallh, wallt, m){
    width = wallt/sin(45);
    rotate([0,0,45])
    if(!valueor(m,false)){
        cube([width,smallsmallvalue,wallh]);
    }else{
        translate([0,-smallsmallvalue,0])
        cube([width,smallsmallvalue,wallh]);
    }
}
module generateKeyHolderWallPart(capsize, wallh, wallt, fl, fr, rf, rb, br, bl, lb, lf, clf, clb, crf, crb){
    if(valueor(fl,false)){
        rotate([0,0,270])
        __generateKeyHolderWallPart(wallh,wallt,true);
    }
    if(valueor(fr,false)){
        translate([capsize[0],0,0])
        rotate([0,0,180])
        __generateKeyHolderWallPart(wallh,wallt);
    }
    if(valueor(rf,false)){
        translate([capsize[0],0,0])
        __generateKeyHolderWallPart(wallh,wallt,true);
    }
    if(valueor(rb,false)){
        translate([capsize[0],capsize[1],0])
        rotate([0,0,270])
        __generateKeyHolderWallPart(wallh,wallt,false);
    }
    if(valueor(br,false)){
        translate([capsize[0],capsize[1],0])
        rotate([0,0,90])
        __generateKeyHolderWallPart(wallh,wallt,false);
    }
    if(valueor(bl,false)){
        translate([0,capsize[1],0])
        rotate([0,0,0])
        __generateKeyHolderWallPart(wallh,wallt,false);
    }

    if(valueor(lf,false)){
        rotate([0,0,90])
          __generateKeyHolderWallPart(wallh,wallt);
    }
    if(valueor(lb,false)){
        translate([0,capsize[1],0])
        rotate([0,0,180])
        __generateKeyHolderWallPart(wallh,wallt,true);
    }

    if(valueor(clf,false)){
        translate([0,-wallt,0])
        generateKeyHolderWallPart(capsize, wallh,wallt,lf=true);
    }
    if(valueor(crf,false)){
        translate([0,-wallt,0])
        generateKeyHolderWallPart(capsize, wallh,wallt,rf=true);
    }
    if(valueor(clb,false)){
        translate([0,wallt,0])
        generateKeyHolderWallPart(capsize, wallh,wallt,lb=true);
    }
    if(valueor(crb,false)){
        translate([0,wallt,0])
        generateKeyHolderWallPart(capsize, wallh,wallt,rb=true);
    }
    
}
module generateKeyHolderFlatWalls(capsize,  wallh, wallt, rwall, lwall, fwall, bwall){
    r = valueor(rwall,false);
    l = valueor(lwall,false);
    f = valueor(fwall,false);
    b = valueor(bwall,false);
    if(r){
        hull(){
            generateKeyHolderWallPart(capsize, wallh, wallt, rf=true);
            generateKeyHolderWallPart(capsize, wallh, wallt, rb=true);
        }
    }
    if(l){
        hull(){
            generateKeyHolderWallPart(capsize, wallh, wallt, lf=true);
            generateKeyHolderWallPart(capsize, wallh, wallt, lb=true);
        }
    }
    if(f){
        hull(){
            generateKeyHolderWallPart(capsize, wallh, wallt, fl=true);
            generateKeyHolderWallPart(capsize, wallh, wallt, fr=true);
        }
    }
    if(b){
        hull(){
            generateKeyHolderWallPart(capsize, wallh, wallt, bl=true);
            generateKeyHolderWallPart(capsize, wallh, wallt, br=true);
        }
    }
    // generate corners
    if( l && f ){
        hull(){
            generateKeyHolderWallPart(capsize, wallh, wallt, lf=true);
            generateKeyHolderWallPart(capsize, wallh, wallt, fl=true);
            generateKeyHolderWallPart(capsize, wallh, wallt, clf=true);
        }
    }
    if( r && f ){
        hull(){
            generateKeyHolderWallPart(capsize, wallh, wallt, rf=true);
            generateKeyHolderWallPart(capsize, wallh, wallt, fr=true);
            generateKeyHolderWallPart(capsize, wallh, wallt, crf=true);
        }
    }
    if( l && b ){
        hull(){
            generateKeyHolderWallPart(capsize, wallh, wallt, lb=true);
            generateKeyHolderWallPart(capsize, wallh, wallt, bl=true);
            generateKeyHolderWallPart(capsize, wallh, wallt, clb=true);
        }
    }
    if( r && b ){
        hull(){
            generateKeyHolderWallPart(capsize, wallh, wallt, rb=true);
            generateKeyHolderWallPart(capsize, wallh, wallt, br=true);
            generateKeyHolderWallPart(capsize, wallh, wallt, crb=true);
        }
    }
}

module generateKeyHolderWalls(switchtype, capsize, wallh, wallt, rwall, lwall, fwall, bwall, lfwall, rfwall, rbwall, lbwall){
    wh = key_holder_height(switchtype) + wallh;
    translate([0,0,-wh]){
        generateKeyHolderFlatWalls(capsize, wh, wallt, rwall, lwall, fwall, bwall);
    }
}

module generateKeyHolderWallAdapter(switchtype, capsize, wallh, wallt, fl,fr,rf,rb,br,bl,lb,lf){
    keyholderheight = key_holder_height(switchtype);
    wh = keyholderheight + wallh;
    translate([0,0,-capsize[2]-keyholderheight-wallh]){
        generateKeyHolderWallPart(capsize, wh, wallt, fl, fr, rf, rb, br, bl, lb, lf);
    }
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
            translate([0,0,1])
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
module generateMxHotswapKeyHolder(capsize, wallh, wallt, rwall, lwall, fwall, bwall, lfwall, rfwall, rbwall, lbwall){
    generateMxKeyHolder(capsize, wallh, wallt, rwall, lwall, fwall, bwall, lfwall, rfwall, rbwall, lbwall);
    MxHotswapPlateSize = [capsize[0],capsize[1],MxHotswapPlateHeight];
    PlateXCenter = MxHotswapPlateSize[0]/2;
    PlateYCenter = MxHotswapPlateSize[1]/2;
    CenterHoleRad = 1.95;
    MountHoleRad = 0.9;
    PinHoleRad = 1.5;
    GridStep = 1.27;
    MountPinStepOff = 4;
    LedX = 5;
    LedY = 3;
    drainhole = [1.5,1.5,MxHotswapPlateSize[2]];
    drainholexoff = (-MxSwitchHoleExt[0]+MxHotswapPlateSize[0])/2;
    drainholeyoff = (-MxSwitchHoleExt[1]+MxHotswapPlateSize[1])/2;
    translate([0,0,-MxSwitchHoleHeight]){
        translate([0,0,-MxHotswapPlateSize[2]])
        difference(){
            // plate
            cube(MxHotswapPlateSize);
            // pins holes
            // center mount
            translate([PlateXCenter,PlateYCenter,0])
            cylinder(r=CenterHoleRad,h=MxHotswapPlateSize[2],$fn=20);
            //left mount
            translate([PlateXCenter-MountPinStepOff*GridStep,PlateYCenter,0])
            cylinder(r=MountHoleRad,h=MxHotswapPlateSize[2],$fn=20);
            //right mount
            translate([PlateXCenter+MountPinStepOff*GridStep,PlateYCenter,0])
            cylinder(r=MountHoleRad,h=MxHotswapPlateSize[2],$fn=20);
            
            // left pin
            translate([PlateXCenter-3*GridStep,PlateYCenter+2*GridStep,0])
            cylinder(r=PinHoleRad,h=MxHotswapPlateSize[2],$fn=20);
            // left pin
            translate([PlateXCenter+2*GridStep,PlateYCenter+4*GridStep,0])
            cylinder(r=PinHoleRad,h=MxHotswapPlateSize[2],$fn=20);

            // led 
            translate([PlateXCenter-LedX/2, PlateYCenter-4*GridStep-LedY/2,0])
            cube([LedX, LedY, MxHotswapPlateSize[2]]);
            
            // drain holes 
            translate([drainholexoff, drainholeyoff,0]){
                //lf
                cube(drainhole);
                // rf
                translate([MxSwitchHoleExt[0]-drainhole[0],0,0])
                cube(drainhole);
                // rb
                translate([MxSwitchHoleExt[0]-drainhole[0],MxSwitchHoleExt[1]-drainhole[1],0])
                cube(drainhole);
                //lb
                translate([0,MxSwitchHoleExt[1]-drainhole[1],0])
                cube(drainhole);
                
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
    translate([0,0,-capsize[2]]){
        swt = switchtype_check(switchtype);
        if(swt == MxSwitchType) generateMxKeyHolder(capsize, wallh, wallt, rwall, lwall, fwall, bwall, lfwall, rfwall, rbwall, lbwall);
        if(swt == MxHotswapSwitchType) generateMxHotswapKeyHolder(capsize, wallh, wallt, rwall, lwall, fwall, bwall, lfwall, rfwall, rbwall, lbwall);

        generateKeyHolderWalls(switchtype, capsize 
            , wallh, wallt, rwall, lwall, fwall, bwall, lfwall, rfwall, rbwall, lbwall);
    }
}
module keyHolderAdapterPart(height) cube([smallsmallvalue, smallsmallvalue, height]);
module generateKeyHolderAdapter(switchtype, capsize, fl, fr, br, bl){
    height = key_holder_height(switchtype);
    translate([0,0,-height-capsize[2]])
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
        lcoln = coln-1;
        lhomeval = valueor(colhome[lcoln],coldefhome);
        start = -rows;
        end = rows*2;
        echo(start);
        echo(end);
        for(rown=[start:1:end]) {
            // left 
            lrown = translateRownToCol(rown, lcoln, colhome, coldefhome, homeval);
            lwall = getKey(matrix, rows, cols, lrown, lcoln);
            
            // left front
            lfcoln = coln-1;
            lfrown = translateRownToCol(rown-1, lfcoln, colhome, coldefhome, homeval);
            lfwall = getKey(matrix, rows, cols, lfrown, lfcoln);

            // front
            fcoln = coln;
            frown = rown-1;
            fwall = getKey(matrix, rows, cols, frown, fcoln);

            // back
            bcoln = coln;
            brown = rown+1;
            bwall = getKey(matrix, rows, cols, brown, bcoln);

            // left back
            lbcoln = coln-1;
            lbrown = translateRownToCol(rown+1,lbcoln, colhome, coldefhome, homeval);
            lbwall = getKey(matrix, rows, cols, lbrown, lbcoln);
            // if there is a key where we are on
            curr = getKey(matrix, rows, cols, rown, coln);
            if(!curr) {
                // surface connector
                if(!lwall){
                    hull(){
                            translateKeyHolder(capsize, homeval, coln, colsrot, colsdefrot, sdefrot, true) translateKeyHolder(capsize, rown, coln, colsrot, colsdefrot, sdefrot)
                            generateKeyHolderAdapter(switchtype, capsize, true, false, false, true);
                        translateSwitchMatrixCol(capsize, coln, pad, defpad, rrot, rdefrot,true) translateSwitchMatrixCol(capsize, lcoln, pad, defpad, rrot, rdefrot)
                        translateKeyHolder(capsize, lhomeval, lcoln, colsrot, colsdefrot, sdefrot, true) translateKeyHolder(capsize, lrown, lcoln, colsrot, colsdefrot, sdefrot)
                                generateKeyHolderAdapter(switchtype, capsize, false, true, true, false);
                    }
                }
                // front wall connector
                if((fwall && lfwall) && !lwall){
                    hull(){
                        translateKeyHolder(capsize, lhomeval, lcoln, colsrot, colsdefrot, sdefrot, true) translateKeyHolder(capsize, lrown, lcoln, colsrot, colsdefrot, sdefrot)
                            generateKeyHolderWallAdapter(switchtype, capsize, wallh, wallt, fl=true);
                        translateSwitchMatrixCol(capsize, coln, pad, defpad, rrot, rdefrot,true) translateSwitchMatrixCol(capsize, lcoln, pad, defpad, rrot, rdefrot)
                            translateKeyHolder(capsize, homeval, coln, colsrot, colsdefrot, sdefrot, true) translateKeyHolder(capsize, rown, coln, colsrot, colsdefrot, sdefrot)
                                generateKeyHolderWallAdapter(switchtype, capsize, wallh, wallt, fr=true);
                    }
                }
                if((bwall && lbwall) && !lwall){
                    hull(){
                        translateKeyHolder(capsize, lhomeval, lcoln, colsrot, colsdefrot, sdefrot, true) translateKeyHolder(capsize, lrown, lcoln, colsrot, colsdefrot, sdefrot)
                            generateKeyHolderWallAdapter(switchtype, capsize, wallh, wallt, bl=true);
                        translateSwitchMatrixCol(capsize, coln, pad, defpad, rrot, rdefrot,true) translateSwitchMatrixCol(capsize, lcoln, pad, defpad, rrot, rdefrot)
                            translateKeyHolder(capsize, homeval, coln, colsrot, colsdefrot, sdefrot, true) translateKeyHolder(capsize, rown, coln, colsrot, colsdefrot, sdefrot)
                                generateKeyHolderWallAdapter(switchtype, capsize, wallh, wallt, br=true);
                    }
                }
            }
            // surface corner connector
            hull(){
                union(){
                if(!curr)
                    __translateKeyHolder(capsize, start, homeval, coln, colsrot, colsdefrot, sdefrot, true) __translateKeyHolder(capsize, start, rown, coln, colsrot, colsdefrot, sdefrot)
                    generateKeyHolderAdapter(switchtype, capsize, true, false, false, false);
                if(!fwall)
                    __translateKeyHolder(capsize, start, homeval, fcoln, colsrot, colsdefrot, sdefrot, true) __translateKeyHolder(capsize, start, frown, fcoln, colsrot, colsdefrot, sdefrot)
                    generateKeyHolderAdapter(switchtype, capsize, false, false, false, true);
                    };

                translateSwitchMatrixCol(capsize, coln, pad, defpad, rrot, rdefrot,true) translateSwitchMatrixCol(capsize, lcoln, pad, defpad, rrot, rdefrot) 
                union(){
                    if(!lwall)
                    __translateKeyHolder(capsize, start, lhomeval, lcoln, colsrot, colsdefrot, sdefrot, true) __translateKeyHolder(capsize, start, lrown, lcoln, colsrot, colsdefrot, sdefrot)
                        generateKeyHolderAdapter(switchtype, capsize, false, true, false, false);
                    if(!lfwall)
                    __translateKeyHolder(capsize,start, lhomeval, lfcoln, colsrot, colsdefrot, sdefrot, true) __translateKeyHolder(capsize,start, lfrown, lfcoln, colsrot, colsdefrot, sdefrot)
                        generateKeyHolderAdapter(switchtype, capsize, false, false, true, false);
                }
            }
            // wall corner connector
            if((bti(!curr) + bti(!lwall) + bti(!lfwall) + bti(!fwall)) == 3)
            hull(){
                union(){
                if(!curr && !lfwall)
                    __translateKeyHolder(capsize, start, homeval, coln, colsrot, colsdefrot, sdefrot, true) __translateKeyHolder(capsize, start, rown, coln, colsrot, colsdefrot, sdefrot)
                    generateKeyHolderWallAdapter(switchtype, capsize, wallh, wallt, fl=!lwall, lf=!fwall);
                if(!fwall && !lwall)
                    __translateKeyHolder(capsize, start, homeval, fcoln, colsrot, colsdefrot, sdefrot, true) __translateKeyHolder(capsize, start, frown, fcoln, colsrot, colsdefrot, sdefrot)
                    generateKeyHolderWallAdapter(switchtype, capsize, wallh, wallt, bl=!lfwall, lb=!curr);
                };

                translateSwitchMatrixCol(capsize, coln, pad, defpad, rrot, rdefrot,true) translateSwitchMatrixCol(capsize, lcoln, pad, defpad, rrot, rdefrot) 
                union(){
                    if(!fwall && !lwall)
                    __translateKeyHolder(capsize, start, lhomeval, lcoln, colsrot, colsdefrot, sdefrot, true) __translateKeyHolder(capsize, start, lrown, lcoln, colsrot, colsdefrot, sdefrot)
                    generateKeyHolderWallAdapter(switchtype, capsize, wallh, wallt, rf=!lfwall, fr=!curr);
                    if(!curr && !lfwall)
                    __translateKeyHolder(capsize,start, lhomeval, lfcoln, colsrot, colsdefrot, sdefrot, true) __translateKeyHolder(capsize,start, lfrown, lfcoln, colsrot, colsdefrot, sdefrot)
                    generateKeyHolderWallAdapter(switchtype, capsize, wallh, wallt, rb=!lwall, br=!fwall);
                }
             
            }
        }
    }
}

module generateSwitchMatrixCol(switchtype, capsize, wallh, wallt, rows, cols, coln,matrix, colsrot, colsdefrot, sdefrot, colhome, coldefhome){
    homeval = valueor(colhome[coln],coldefhome);
    translateKeyHolder(capsize, homeval, coln, colsrot, colsdefrot, sdefrot, true)
    for(rown=[0:1:rows-1]) {
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

        lfwall = getKey(matrix, rows, cols, lrown-1, lcoln);
        rfwall = getKey(matrix, rows, cols, rrown-1, rcoln);
        rbwall = getKey(matrix, rows, cols, rrown+1, rcoln);
        lbwall = getKey(matrix, rows, cols, lrown+1, lcoln);
        if(valueor(matrix[rown][coln],true)) {

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
        // walls
        if(rown > 0){
            // lf
            if(lwall && !fwall && lfwall){
                hull(){
                translateKeyHolder(capsize, rown, coln, colsrot, colsdefrot, sdefrot)
                    generateKeyHolderWallAdapter(switchtype, capsize, wallh,wallt, lf=true);
                translateKeyHolder(capsize, rown-1, coln, colsrot, colsdefrot, sdefrot)
                    generateKeyHolderWallAdapter(switchtype, capsize, wallh,wallt, lb=true);
                }
            }
            if(rwall && !fwall && rfwall){
                hull(){
                translateKeyHolder(capsize, rown, coln, colsrot, colsdefrot, sdefrot)
                    generateKeyHolderWallAdapter(switchtype, capsize, wallh,wallt, rf=true);
                translateKeyHolder(capsize, rown-1, coln, colsrot, colsdefrot, sdefrot)
                    generateKeyHolderWallAdapter(switchtype, capsize, wallh,wallt, rb=true);
                }
            }
        }
    }
}

// generate whole matrix with walls
module generateSwitchMatrix(switchtype, capsize,wallh, lidt,wallt, rows,cols, matrix, homecol, pad, defpad,rrot,rdefrot, colsrot, colsdefrot, sdefrot, colhome, coldefhome){
    wh = wallh_normalize(switchtype, wallh)+valueor_lowcap(lidt,2);
    cs = capsize_normalize(switchtype, capsize);
    homecolval = valueor(homecol, 0);
    translateSwitchMatrixCol(cs, homecolval, pad, defpad, rrot, rdefrot, true)
    for(coln=[0:1:cols-1]){
        translateSwitchMatrixCol(cs, coln,pad,defpad,rrot,rdefrot) union(){
            if(coln != 0){
                generateSwitchMatrixColAdapter(switchtype, cs, wh, wallt, rows, cols, coln,matrix,pad, defpad,rrot,rdefrot, colsrot, colsdefrot, sdefrot, colhome, coldefhome);
            }
            generateSwitchMatrixCol(switchtype, cs, wh, wallt, rows, cols, coln, matrix, colsrot, colsdefrot, sdefrot, colhome, coldefhome);
        }
    }
}


//generateKeyHolder(switchtype = MxHotswapSwitchType, capsize = [20,20,20], wallh = 0, wallt = 0, rwall = rwall, lwall = lwall, fwall = fwall, bwall = bwall, lfwall = lfwall, rfwall = rfwall, rbwall = rbwall, lbwall = lbwall);
///*
generateSwitchMatrix(
switchtype=MxHotswapSwitchType, 
capsize = [20,20,20],
wallh = 5,
wallt = 3,
rows = 3,
cols = 3,
matrix = [
  [true,true, false],
  [true,true],
],
homecol = 1,
pad = [],
defpad = [2,2,2],
rrot = [],
rdefrot = [0,-5,0],
colsrot = [],
colsdefrot = [[10,0,0],[20,0,0],[30,0,0]],
sdefrot = [3, 0,0],
colhome = [0],
coldefhome = 1
);
//*/
