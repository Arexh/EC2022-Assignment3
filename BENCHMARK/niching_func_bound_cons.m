function [lb,ub]=niching_func_bound_cons(funcNum, dims,varargin)
bounds = nan(dims,2);



switch(funcNum)
    case{10}
        bounds(:,1)=0.0d0;
        bounds(:,2)=1.0d0;
    case{11,12}
        bounds(:,1)=-6.0d0;
        bounds(:,2)=6.0d0;
    case{13,14,15,16,17,18}
        bounds(:,1)=0.0d0;
        bounds(:,2)=2.0d0;
    case{20}
        bounds(:,1)=-100.0d0;
        bounds(:,2)=100.0d0;
    case{21}
        bounds(:,1)=0.5d0;
        bounds(:,2)=4.5d0;
    case{30:39}
        bounds(:,1)=-real(dims+1);
        bounds(:,2)=real(dims+1);
    otherwise
        bounds(:,1)=-real(dims+1);
        bounds(:,2)=real(dims+1);
end %select;
lb = bounds(:,1)';
ub = bounds(:,2)';
end %subroutine
