function [fitness,g,h]=niching_func_cons(x,funcNum,varargin)

%     NEIGHBOURHOOD-BASED SPECIATION DIFFERNETIAL EVOLUTION MULTIMODAL
%     OPTIMIZER WITH FEASIBLE SELECTION FOR CONSTRAINTS.
%
%     Copyright 2018 Daniel Poole
%
%     Permission is hereby granted, free of charge, to any person
%     obtaining a copy of this software and associated documentation
%     files (the 'Software'), to deal in the Software without restriction,
%     including without limitation the rights to use, copy, modify, merge,
%     publish, distribute, sublicense, and/or sell copies of the Software,
%     and to permit persons to whom the Software is furnished to do so,
%     subject to the following conditions:
%
%     The above copyright notice and this permission notice shall be
%     included in all copies or substantial portions of the Software.
%
%     THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
%     EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
%     OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
%     NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
%     BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
%     AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
%     IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
%     THE SOFTWARE.




persistent conseps heavi i obj1 obj2 pi x1 x2 x3 x4 y1 y2 y3 y4 ;

if isempty(i), i=0; end
if isempty(heavi), heavi=0; end
if isempty(pi), pi=0; end
if isempty(obj1), obj1=0; end
if isempty(obj2), obj2=0; end
if isempty(x1), x1=0; end
if isempty(x2), x2=0; end
if isempty(x3), x3=0; end
if isempty(x4), x4=0; end
if isempty(y1), y1=0; end
if isempty(y2), y2=0; end
if isempty(y3), y3=0; end
if isempty(y4), y4=0; end
if isempty(conseps), conseps=0; end
k=[];
Dim = size(x,2);
pi=4.0d0.*atan(1.0d0);
conseps=1.0e-4;
cons=[1,1,2,1,3,5,1,3,5,1];
NP = size(x,1);
h = zeros(NP,0);
g = zeros(NP,0);
eps_viol = 1e-4;
switch(funcNum)

    case{10}

        fitness=-sin(5.0d0.*pi.*x(:,1)).^6+1.0d0;
        g(:,1)=-cos(10.0d0.*pi.*x(:,1));

    case{11}

        %       HIMMELBLAU CONSTRAINED BY QUADRATICS SUCH THAT ONE CONSTRAINT
        %       TOUCHES TWO OPTIMAL POINTS, THEREFORE AT EACH OPTIMAL POINT,
        %       TWO CONSTRAINTS ARE ACTIVE

        fitness=(x(:,1).^2+x(:,2)-11.0d0).^2+(x(:,1)+x(:,2).^2-7.0d0).^2+1.0d0;

        x1=3.0d0;
        y1=2.0d0;
        x2=-2.805118d0;
        y2=3.131312d0;
        x3=-3.779310d0;
        y3=-3.283186d0;
        x4=3.584428d0;
        y4=-1.848126d0;

        g(:,1)=(x1.*x2)-(x1.*x(:,1))-(x2.*x(:,1))+(y1.*y2)-(y1.*x(:,2))-(y2.*x(:,2))+(x(:,1).^2)+(x(:,2).^2);
        g(:,2)=(x2.*x3)-(x2.*x(:,1))-(x3.*x(:,1))+(y2.*y3)-(y2.*x(:,2))-(y3.*x(:,2))+(x(:,1).^2)+(x(:,2).^2);
        g(:,3)=(x3.*x4)-(x3.*x(:,1))-(x4.*x(:,1))+(y3.*y4)-(y3.*x(:,2))-(y4.*x(:,2))+(x(:,1).^2)+(x(:,2).^2);
        g(:,4)=(x4.*x1)-(x4.*x(:,1))-(x1.*x(:,1))+(y4.*y1)-(y4.*x(:,2))-(y1.*x(:,2))+(x(:,1).^2)+(x(:,2).^2);

        g(:)=-g(:);

    case{12}

        %       HIMMELBLAU CONSTRAINED BY QUADRATICS AND PLANES SUCH THAT
        %       AT EACH OPTIMAL POINT THREE CONSTRAINTS ARE ACTIVE.
        %       OPTIMAL POINTS AT SINGLE POINT WHERE CONS ARE ACTIVE

        fitness=(x(:,1).^2+x(:,2)-11.0d0).^2+(x(:,1)+x(:,2).^2-7.0d0).^2+1.0d0;

        x1=3.0d0;
        y1=2.0d0;
        x2=-2.805118d0;
        y2=3.131312d0;
        x3=-3.779310d0;
        y3=-3.283186d0;
        x4=3.584428d0;
        y4=-1.848126d0;

        g(:,1)=(x1.*x2)-(x1.*x(:,1))-(x2.*x(:,1))+(y1.*y2)-(y1.*x(:,2))-(y2.*x(:,2))+(x(:,1).^2)+(x(:,2).^2);
        g(:,2)=(x2.*x3)-(x2.*x(:,1))-(x3.*x(:,1))+(y2.*y3)-(y2.*x(:,2))-(y3.*x(:,2))+(x(:,1).^2)+(x(:,2).^2);
        g(:,3)=(x3.*x4)-(x3.*x(:,1))-(x4.*x(:,1))+(y3.*y4)-(y3.*x(:,2))-(y4.*x(:,2))+(x(:,1).^2)+(x(:,2).^2);
        g(:,4)=(x4.*x1)-(x4.*x(:,1))-(x1.*x(:,1))+(y4.*y1)-(y4.*x(:,2))-(y1.*x(:,2))+(x(:,1).^2)+(x(:,2).^2);
        g(:,[1:4])=-g(:,[1:4]);

        g(:,5)=(x(:,1)-x1)+(x(:,2)-y1);
        g(:,6)=-(x(:,1)-x2)+(x(:,2)-y2);
        g(:,7)=-(x(:,1)-x3)-(x(:,2)-y3);
        g(:,8)=(x(:,1)-x4)-(x(:,2)-y4);

    case{13,14,15,16,17,18}

        %       MODULO-MODIFIED RASTRIGIN: DEB'S MODIFIED RASTRIGIN BUT FOR X<1, NO
        %       X^2 UNDERLYING TREND - CAUSES PROBLEM TO HAVE GLOBAL AND LOCAL
        %       MINIMA. CREATED BY D. POOLE.

        k=zeros(1,Dim);

        switch(funcNum)
            case{13}
                k(1)=1.0d0;
            case{14}
                k(1)=5.0d0;
            case{15}
                k(1)=1.0d0;
                k(2)=2.0d0;
            case{16}
                k(1)=2.0d0;
                k(2)=3.0d0;
            case{17}
                k(1)=1.0d0;
                k(2)=1.0d0;
                k(3)=2.0d0;
            case{18}
                k(1)=1.0d0;
                k(2)=1.0d0;
                k(3)=1.0d0;
                k(4)=1.0d0;
                k(5)=2.0d0;
        end %select;

        obj1=0.0d0;
        obj2=0.0d0;
        for i=1:Dim
            [heavi]=heaviside(x(:,i)-1.0d0);
            obj1=obj1+(10.0d0.*(1.0d0+cos(2.0d0.*pi.*k(i).*x(:,i)))+(2.0d0.*k(i).*(x(:,i)-1.0d0).^2.*heavi));

            obj2=obj2+(20.0d0.*cos(4.0d0.*pi.*k(i).*x(:,i)));
        end; i=fix(Dim+1);
        fitness=obj1;
        g(:,1)=obj2;

    case{20}

        obj1=0.0d0;
        obj2=0.0d0;
        for i=1:Dim
            obj1=obj1+(10.0d0.*cos(0.1d0.*x(:,i)));
            obj2=obj2+(x(:,i).*cos(sqrt(abs(x(:,i)))));
        end; i=fix(Dim+1);
        fitness=obj1;
        g(:,1)=obj2;
        g(:,1)=abs(g(:,1))-conseps;

    case{21}

        x1=x(:,1);
        x2=x(:,2);
        fitness=(x1.^2+x1+x2.^2+2.1d0.*x2)+10.0d0.*(1.0d0-cos(2.0d0.*pi.*x1))+10.0d0.*(1.0d0-cos(2.0d0.*pi.*x2));
        fitness=10.0d0.*(1.0d0-cos(2.0d0.*pi.*x1))+10.0d0.*(1.0d0-cos(2.0d0.*pi.*x2));
        g(:,1)=-0.0d0;

    otherwise
        [fitness, g]=CMMP(Dim, cons(funcNum), x);
end %select
%conVio = sum_vio(h,g,eps_viol,NP);
g(g<1e-10) = 0;
%contains;

    function [heavisideresult,x]=heaviside(x,varargin)
    heavisideresult=[];


    if(x>=0.0d0)
        heavisideresult=1;
    else
        heavisideresult=0;
    end
    end %function

end %subroutine niching_func_cons








function [f,g] = CMMP(n,j,x)
np = size(x,1);
f = sum(x.^2,2);
g = zeros(np,j );
for jj = 1:j
    c = (n-jj+1) + [1:n];
    c = mod(c,n );
    c(c==0) = n;
    g(:,jj) = n^2 - sum(c.^2.*x.^2, 2);
end
end
function [viol]=sum_vio(h,g,eps_viol,N)
% vraci sloupcovy vektor violation prislusny k maticim g,h, v nichz kazdy
% radek je vektorem g(resp.h) odpovidajim jednomu bodu
%
% h=h';
% g=g';


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
