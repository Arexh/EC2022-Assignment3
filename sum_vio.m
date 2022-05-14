function [viol]=sum_vio(g,h,eps_viol)
% vraci sloupcovy vektor violation prislusny k maticim g,h, v nichz kazdy
% radek je vektorem g(resp.h) odpovidajim jednomu bodu
%
% h=h';
% g=g';

N = size([g,h],1);
sumH=zeros(N,1);
sumG=zeros(N,1);
if ~isempty(h)
    for i=1:N
        h1=h(i,:);
        Hpom=abs(h1);
        Hpom(Hpom<=eps_viol)=0;
        sumH(i,1)=sum(Hpom);
    end    
end    
if ~isempty(g)
    for i=1:N
        g1=g(i,:);
        Gpom=g1;
        Gpom(Gpom<=0)=0;
        sumG(i,1)=sum(Gpom);  
    end    
end    
sumG(sumG<1e-10) = 0;
viol=(sumH+sumG);
end