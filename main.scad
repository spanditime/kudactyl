smallsmallvalue = 0.1;
// util functions
function valueor(value,orvalue) = is_undef(value) ? orvalue : value; 
function valueor_cap(value, cap) = is_undef(value) ? cap : (value>cap ? cap : value);
function valueor_lowcap(value, cap) = is_undef(value) ? cap : (value<cap ? cap : value);

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

// MX HOTSWAP 
MxHotswapPlateHeight = 1.5;
MxHotswapSwitchHoleHeight = MxSwitchHoleHeight+MxHotswapPlateHeight;
MxHotswapSwitchMinWallh = 5;

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

module __generateKeyHolderWalls(capsize, keyholderheight, keyholderclearence, wallh, wallt, rwall, lwall, fwall, bwall, lfwall, rfwall, rbwall, lbwall){
    xw = wallt_normalize(wallt, capsize[0], keyholderclearence[0]); 
    yw = wallt_normalize(wallt, capsize[1], keyholderclearence[1]);
    translate([0,0,-keyholderheight]){
        generateKeyHolderFlatWalls(capsize, wallh, xw, yw, rwall, lwall, fwall, bwall);
        generateKeyHolderCornerWalls(capsize, wallh, xw, yw, lfwall, rfwall, rbwall, lbwall);
    }
}
module generateKeyHolderWalls(switchtype, capsize, wallh, wallt, rwall, lwall, fwall, bwall, lfwall, rfwall, rbwall, lbwall){
    __generateKeyHolderWalls(capsize = capsize, keyholderheight = key_holder_height(switchtype), keyholderclearence = key_holder_clearence(switchtype)
    , wallh = wallh, wallt = wallt, rwall = rwall, lwall = lwall, fwall = fwall, bwall = bwall, lfwall = lfwall, rfwall = rfwall, rbwall = rbwall, lbwall = lbwall);
}

module KeyHolderWallAdapterPart(capsize, wallh, xw, yw) {
    translate([0,0,-wallh]){
        if(!is_undef(xw)){
            cube([xw,smallsmallvalue, wallh]);
        }
        if(!is_undef(yw)){
            cube([smallsmallvalue,yw, wallh]);
        }
    }
}
module __generateKeyHolderWallAdapter(capsize, keyholderclearence, keyholderheight, wallh, wallt, fl,fr,rf,rb,br,bl,lb,lf){
    xw = wallt_normalize(wallt, capsize[0], keyholderclearence[0]); 
    yw = wallt_normalize(wallt, capsize[1], keyholderclearence[1]);
    fbxt = capsize[0]-xw; // front-to-back x translate
    fbyt = capsize[1]-smallsmallvalue; // front-to-back y translate
    lrxt = capsize[0]-smallsmallvalue; // left-to-right x translate
    lryt = capsize[1]-yw; // left-to-right y translate
    translate([0,0,-capsize[2]-keyholderheight]){
        //front
        {
            if(fl) KeyHolderWallAdapterPart(capsize, wallh, xw = xw);
            if(fr) translate([fbxt,0,0]) KeyHolderWallAdapterPart(capsize, wallh, xw = xw);
        }
        //back
        translate([0,fbyt,0]){
            if(bl) KeyHolderWallAdapterPart(capsize, wallh, xw = xw);
            if(br) translate([fbxt,0,0]) KeyHolderWallAdapterPart(capsize, wallh, xw = xw);
        }
        // left
        {
            if(lf) KeyHolderWallAdapterPart(capsize, wallh, yw = yw);
            if(lb) translate([0,lryt,0]) KeyHolderWallAdapterPart(capsize, wallh, yw = yw);
        }
        // right
        translate([lrxt, 0, 0]){
            if(rf) KeyHolderWallAdapterPart(capsize, wallh, yw = yw);
            if(rb) translate([0,lryt,0]) KeyHolderWallAdapterPart(capsize, wallh, yw = yw);
        }
    }
}
module generateKeyHolderWallAdapter(switchtype, capsize, wallh, wallt, fl,fr,rf,rb,br,bl,lb,lf){
    __generateKeyHolderWallAdapter(capsize = capsize, 
    keyholderclearence = key_holder_clearence(switchtype),
    keyholderheight = key_holder_height(switchtype),
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
        lhomeval = valueor(colhome[coln-1],coldefhome);
        for(rown=[0:1:rows-1]) {
            if(valueor(matrix[rown][coln],true)) {
                // left 
                lcoln = coln-1;
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
                
                // surface connector
                if(!lwall){
                    hull(){
                        translateKeyHolder(capsize, lhomeval, lcoln, colsrot, colsdefrot, sdefrot, true) translateKeyHolder(capsize, lrown, lcoln, colsrot, colsdefrot, sdefrot)
                            generateKeyHolderAdapter(switchtype, capsize, true, false, false, true);
                        translateSwitchMatrixCol(capsize, coln, pad, defpad, rrot, rdefrot,true) translateSwitchMatrixCol(capsize, lcoln, pad, defpad, rrot, rdefrot)
                            translateKeyHolder(capsize, homeval, coln, colsrot, colsdefrot, sdefrot, true) translateKeyHolder(capsize, rown, coln, colsrot, colsdefrot, sdefrot)
                                generateKeyHolderAdapter(switchtype, capsize, false, true, true, false);
                    }
                }
                // surface corner connector
                if(!lwall && !lfwall && !fwall){
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
                // front wall connector
                if((fwall || lfwall) && !lwall){
                    hull(){
                        translateKeyHolder(capsize, lhomeval, lcoln, colsrot, colsdefrot, sdefrot, true) translateKeyHolder(capsize, lrown, lcoln, colsrot, colsdefrot, sdefrot)
                            generateKeyHolderWallAdapter(switchtype, capsize, wallh, wallt, lf=true);
                        translateSwitchMatrixCol(capsize, coln, pad, defpad, rrot, rdefrot,true) translateSwitchMatrixCol(capsize, lcoln, pad, defpad, rrot, rdefrot)
                            translateKeyHolder(capsize, homeval, coln, colsrot, colsdefrot, sdefrot, true) translateKeyHolder(capsize, rown, coln, colsrot, colsdefrot, sdefrot)
                                generateKeyHolderWallAdapter(switchtype, capsize, wallh, wallt, rf=true);
                    }
                }
                if((bwall || lbwall) && !lwall){
                    hull(){
                        translateKeyHolder(capsize, lhomeval, lcoln, colsrot, colsdefrot, sdefrot, true) translateKeyHolder(capsize, lrown, lcoln, colsrot, colsdefrot, sdefrot)
                            generateKeyHolderWallAdapter(switchtype, capsize, wallh, wallt, lb=true);
                        translateSwitchMatrixCol(capsize, coln, pad, defpad, rrot, rdefrot,true) translateSwitchMatrixCol(capsize, lcoln, pad, defpad, rrot, rdefrot)
                            translateKeyHolder(capsize, homeval, coln, colsrot, colsdefrot, sdefrot, true) translateKeyHolder(capsize, rown, coln, colsrot, colsdefrot, sdefrot)
                                generateKeyHolderWallAdapter(switchtype, capsize, wallh, wallt, rb=true);
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
        if(valueor(matrix[rown][coln],true)) {

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
        // walls
        if(rown > 0){
            // lf
            if((lwall || lfwall) && !fwall){
                hull(){
                translateKeyHolder(capsize, rown, coln, colsrot, colsdefrot, sdefrot)
                    generateKeyHolderWallAdapter(switchtype, capsize, wallh,wallt, fl=true);
                translateKeyHolder(capsize, rown-1, coln, colsrot, colsdefrot, sdefrot)
                    generateKeyHolderWallAdapter(switchtype, capsize, wallh,wallt, bl=true);
                }
            }
            if((rwall || rfwall) && !fwall){
                hull(){
                translateKeyHolder(capsize, rown, coln, colsrot, colsdefrot, sdefrot)
                    generateKeyHolderWallAdapter(switchtype, capsize, wallh,wallt, fr=true);
                translateKeyHolder(capsize, rown-1, coln, colsrot, colsdefrot, sdefrot)
                    generateKeyHolderWallAdapter(switchtype, capsize, wallh,wallt, br=true);
                }
            }
        }
    }
}

// generate whole matrix with walls
module generateSwitchMatrix(switchtype, capsize,wallh, lidt,wallt, rows,cols, matrix, homecol, pad, defpad,rrot,rdefrot, colsrot, colsdefrot, sdefrot, colhome, coldefhome){
    wh = wallh_normalize(switchtype, wallh)+valueor_lowcap(lidt,2);
    homecolval = valueor(homecol, 0);
    translateSwitchMatrixCol(capsize, homecolval, pad, defpad, rrot, rdefrot, true)
    for(coln=[0:1:cols-1]){
        translateSwitchMatrixCol(capsize, coln,pad,defpad,rrot,rdefrot) union(){
            if(coln != 0){
                generateSwitchMatrixColAdapter(switchtype, capsize, wh, wallt, rows, cols, coln,matrix,pad, defpad,rrot,rdefrot, colsrot, colsdefrot, sdefrot, colhome, coldefhome);
            }
            generateSwitchMatrixCol(switchtype, capsize, wh, wallt, rows, cols, coln, matrix, colsrot, colsdefrot, sdefrot, colhome, coldefhome);
        }
    }
}


//generateKeyHolder(switchtype = MxHotswapSwitchType, capsize = [20,20,20], wallh = 0, wallt = 0, rwall = rwall, lwall = lwall, fwall = fwall, bwall = bwall, lfwall = lfwall, rfwall = rfwall, rbwall = rbwall, lbwall = lbwall);
///*
generateSwitchMatrix(
switchtype=MxHotswapSwitchType, 
capsize = [20,20,20],
wallh = 5,
wallt = 20,
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
colsdefrot = [],
sdefrot = [3, 0,0],
colhome = [],
coldefhome = 1
);
//*/
