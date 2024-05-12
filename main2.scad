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

module __translateSwitchMatrixCol(capsize, i,coln,pad,defpad,rrot,rdefrot){
    if(i < coln){
        p = valueor(pad[i], defpad);
        r = valueor(rrot[i], rdefrot);
        translate([capsize[0],0,0]) translate(p) rotate(r) __translateSwitchMatrixCol(capsize, i+1,coln,pad,defpad,rrot,rdefrot) children();
    }else{
        children();
    }
}
module translateSwitchMatrixCol(capsize, coln,pad,defpad,rrot,rdefrot){
    __translateSwitchMatrixCol(capsize, 0,coln,pad,defpad,rrot,rdefrot) children();
}

// generate whole matrix with walls where needed
module generateSwitchMatrix(switchtype, capsize,wallh,wallt, rows,cols, matrix, pad, defpad,rrot,rdefrot){
    // generateMxKeyHolder([18,18,1],7,2,true,true,true,true);
    for(rown=[0:1:rows-1]) for(coln=[0:1:cols-1]){
        if(valueor(matrix[rown][coln],true)) {
            brown = rown+1;
            frown = rown-1;
            rcoln = coln+1;
            lcoln = coln-1;
            rwall = rcoln < 0 || rcoln >= cols ? true : (!valueor(matrix[rown][rcoln],true));
            lwall = lcoln < 0 || lcoln >= cols ? true : (!valueor(matrix[rown][lcoln],true));
            fwall = frown < 0 || frown >= rows ? true : (!valueor(matrix[frown][coln],true));
            bwall = brown < 0 || brown >= rows ? true : (!valueor(matrix[brown][coln],true));
            translateSwitchMatrixCol(capsize, coln,pad,defpad,rrot,rdefrot)
            translate([0,capsize[1]*rown,0])
            generateKeyHolder(switchtype, capsize, wallh,wallt,rwall,lwall,fwall,bwall);
        }
    }
}

generateSwitchMatrix(MxSwitchType, [20,20,20],20,20, 4,5,
[
  [false,false],
  [],
],
[],[2,0,0],
[],[2,-10,0]);
