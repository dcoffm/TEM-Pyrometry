function this = RunModel(this)
    if this.writeEmiss
        this.ModelEmiss();
    end
    this.SpectrometerModel(1);
    this.laserFits = this.laserScale;
end