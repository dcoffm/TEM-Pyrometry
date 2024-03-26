function this = CopyParent(this,parent)
    this.x   = parent.x;
    this.nx  = parent.nx;
    this.TSE = parent.TSE;
    this.FOV = parent.FOV;
    this.BoxFactor   = parent.BoxFactor;
    this.ADCoffset   = parent.ADCoffset;
    this.darkCurrent = parent.darkCurrent;
    this.laserCurrent= parent.laserCurrent;
    this.laserScale  = parent.laserScale;
    this.dataMask    = parent.dataMask;
end