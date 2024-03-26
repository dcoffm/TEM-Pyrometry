function this = ModelEmiss(this)
    for i = 1:this.nd
        this.EmissB(i) = this.Bintercept + this.Bslope * this.T(i);
        this.Emiss(:,i) = this.EmissA(i) * (1 + this.EmissB(i)*(this.x - this.x0));
    end    
    if this.standalone % Ensure Atarget doesn't do anything in error function
        this.Atarget = this.EmissA;
    end
end