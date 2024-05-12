MxKeyPlaceSize = [[ 20, 20, 12 ], [[20,20,12],[0,0,0]],[[15,15,8],[2.5,2.5,4]]];
MxBackplatePlaceSize = [[20,20,12], [[15,15,2.5],[2.5,2.5,0]], undef];
//MxBackplatePlaceSize = [[20,20,12], [20,20,2.5], undef];

function valueor(value, default) = is_undef(value) ? default : value;

module KeyPlaceTranslate(size)
{
    translate([ size[1][1][0], size[1][1][1], -13-size[0][2]-size[1][1][2] ]) children();
}

module KeyPlaceSimple(size){
    difference(){
        KeyPlaceTranslate(size) cube(size[1][0]);
        if(!is_undef(size[2])){
            KeyPlaceTranslate(size) translate(size[2][1]) cube(size[2][0]);
        }
    }
}
// mode is either one of 0-1-2-3
module KeyPlaceSideAdapter(size, mode = 0)
{
    KeyPlaceTranslate(size)
    if (mode % 2 == 0)
    {
        if (mode == 2)
            translate([ size[1][1][0], size[0][1]+size[1][1][1], size[1][1][2] ]) cube([ size[1][0][0], 0.000001, size[1][0][2] ]);
        else
            cube([ size[1][0][0], 0.000001, size[1][0][2] ]);
    }
    else
    {
        if(mode == 3)
        translate([size[0][0],0,0]) cube([ 0.000001, size[1][1], size[1][2] ]);
        else
        cube([ 0.000001, size[1][1], size[1][2] ]);
    }
}

module underHomeColumn(keyplacesize, i, home, rotations)
{
    if (i < home)
    {
        hull()
        {
            translate([ 0, keyplacesize[0][1], 0 ]) rotate([ rotations[home - 1 - i], 0, 0 ])
                KeyPlaceSideAdapter(keyplacesize);
            translate([ 0, keyplacesize[0][1], 0 ]) KeyPlaceSideAdapter(keyplacesize);
        }
        translate([ 0, keyplacesize[0][1], 0 ]) rotate([ rotations[home - 1 - i], 0, 0 ])
        {
            KeyPlaceSimple(keyplacesize);
            underHomeColumn(keyplacesize, i + 1, home, rotations);
        }
    }
}
module overHomeColumn(keyplacesize, i, num, rotations)
{
    if (i < num - 1)
    {
        hull()
        {
            KeyPlaceSideAdapter(keyplacesize);
            rotate([ -rotations[i], 0, 0 ]) KeyPlaceSideAdapter(keyplacesize);
        }
        rotate([ -rotations[i], 0, 0 ]) translate([ 0, -keyplacesize[0][1], 0 ])
        {
            KeyPlaceSimple(keyplacesize);
            overHomeColumn(keyplacesize, i + 1, num, rotations);
        }
    }
}
module keyColumn(keyplacesize, num, home, rotations)
{
    underHomeColumn(keyplacesize, 0, home, rotations);
    KeyPlaceSimple(keyplacesize);
    overHomeColumn(keyplacesize, home, num, rotations);
}
module underHomeRowColAdaptor(keyplacesize, i, rhome, cnum, cnumd, chome, chomed, lpad, crot,crotd){
  hull(){
      KeyPlaceSideAdapter(keyplacesize, 1);
      translate(lpad) KeyPlaceSideAdapter(keyplacesize, 3);
  }
}

module underHomeRow(keyplacesize, i, rhome, cnum, cnumd, chome,chomed, cpad,cpadd, crot,crotd)
{
    pad = valueor(cpad[rhome-1-i], cpadd);
    lpad = [ -pad[0]-keyplacesize[0][0], -pad[1], -pad[2] ];
    if (i < rhome){
        // adaptor
        underHomeRowColAdaptor(keyplacesize, i, rhome, cnum, cnumd, chome, chomed, lpad, crot, crotd);
        // the column itself
        translate(lpad)
        {
            keyColumn(keyplacesize, valueor(cnum[rhome - 1 - i],cnumd), valueor(chome[rhome - 1 - i],chomed), valueor(crot[rhome - 1 - i],crotd));
            underHomeRow(keyplacesize, i + 1, rhome, cnum, cnumd, chome,chomed, cpad,cpadd, crot,crotd);
        }
    }
}

module overHomeRow(keyplacesize, i, rnum, cnum, cnumd, chome,chomed,cpad,cpadd, crot,crotd)
{
    pad = valueor(cpad[i], cpadd);
    lpad = [ keyplacesize[0][0]+pad[0], pad[1], pad[2] ];
    if (i < rnum)
        translate(lpad)
        {
            keyColumn(keyplacesize, valueor(cnum[i],cnumd), valueor(chome[i],chomed), valueor(crot[i],crotd));
            overHomeRow(keyplacesize, i + 1, rnum, cnum,cnumd, chome,chomed, cpad,cpadd, crot,crotd);
        }
}

module keySurface(keyplacesize, rnum, rhome, cpad, cnum, cnumd, chome,chomed, cpad, cpadd, crot, crotd)
{
    underHomeRow(keyplacesize, 0, rhome, cnum,cnumd, chome, chomed, cpad,cpadd, crot, crotd);
    keyColumn(keyplacesize, valueor(cnum[rhome],cnumd), valueor(chome[rhome],chomed), valueor(crot[rhome],crotd));
    overHomeRow(keyplacesize, rhome + 1, rnum, cnum, cnumd, chome, chomed, cpad, cpadd, crot, crotd);
}
intersection(){
#keySurface(
    keyplacesize = MxKeyPlaceSize,
    rnum = 4,
    rhome = 3,
    cnum = [ 3, 3, 4, 3 ],
    cnumd = 3,
    chome = [ 1, 1, 1, 1 ],
    chomed = 1,
    // cpad = [ [10,10,10] ],
    cpadd = [2,2,2],
    crot = [ undef, [ 70, 10 ], [ 50, 30, 20 ], [ 10, 40 ] ],
    crotd = [10,20]);
keySurface(
    keyplacesize = MxBackplatePlaceSize,
    rnum = 4,
    rhome = 3,
    cnum = [ 3, 3, 4, 3 ],
    cnumd = 3,
    chome = [ 1, 1, 1, 1 ],
    chomed = 1,
    // cpad = [ [10,10,10] ],
    cpadd = [2,2,2],
    crot = [ undef, [ 70, 10 ], [ 50, 30, 20 ], [ 10, 40 ] ],
    crotd = [10,20]);
    }
