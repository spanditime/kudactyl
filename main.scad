MxKeyPlaceSize = [20,10,5];

module KeyPlaceTranslate(size){
    translate([0, 0, -size[2]]) children();
}

module KeyPlaceSimple(size) KeyPlaceTranslate(size) cube(size);
module KeyPlaceUnderAdapter(size) KeyPlaceTranslate(size) cube([size[0], 0.000001,size[2]]);

module underHomeColumn(keyplacesize, i, home, rotations){
    if(i < home){
        hull(){
            #translate([0,keyplacesize[1],0]) rotate([rotations[home-1-i], 0, 0]) KeyPlaceUnderAdapter(keyplacesize);
            translate([0,keyplacesize[1],0]) KeyPlaceUnderAdapter(keyplacesize);
        }
        translate([0,keyplacesize[1],0]) rotate([rotations[home-1-i], 0, 0]) {
            KeyPlaceSimple(keyplacesize);
            underHomeColumn(keyplacesize, i+1, home, rotations);
        }
    }
}

module overHomeColumn(keyplacesize, i, num, rotations){
    if(i<num-1)
    rotate([-rotations[i],0,0]) translate([0, -keyplacesize[1],0]) { KeyPlaceSimple(keyplacesize);
    overHomeColumn(keyplacesize, i+1, num, rotations);
    }
}

module keyColumn(keyplacesize, num, home, rotations) {
    underHomeColumn(keyplacesize, 0, home, rotations);
    KeyPlaceSimple(keyplacesize);
    overHomeColumn(keyplacesize, home, num, rotations);
}

module underHomeRow(keyplacesize, i, rhome, cnum, chome, crot){
    if(i<rhome) 
        translate([-keyplacesize[0], 0, 0]) { 
            keyColumn(keyplacesize, cnum[rhome-1-i], chome[rhome-1-i], crot[rhome-1-i]);
            underHomeRow(keyplacesize, i+1, rnum, cnum, chome, crot);
        }
}

module overHomeRow(keyplacesize, i, rnum, cnum, chome, crot) {
    if(i<rnum) 
        translate([keyplacesize[0], 0, 0]) { 
            keyColumn(keyplacesize, cnum[i], chome[i], crot[i]);
            overHomeRow(keyplacesize, i+1, rnum, cnum, chome, crot);
        }
}

module keySurface(keyplacesize, rnum, rhome, cnum, chome, crot){
    underHomeRow(keyplacesize, 0, rhome, cnum, chome, crot);
    keyColumn(keyplacesize, cnum[rhome],chome[rhome],crot[rhome]);
    overHomeRow(keyplacesize, rhome+1, rnum, cnum, chome,crot);
}
//keyColumn(MxKeyPlaceSize,6,4,[10,20,30,40,50]);
keySurface(MxKeyPlaceSize,4,1,[3,3,3,3],[1,1,1,1],[[30,20],[70,10],[50,30],[10,40]]);






