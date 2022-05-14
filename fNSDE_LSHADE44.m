function [population] = fNSDE_LSHADE44(problem)%
% problem.epsim : 忽略等式约束的限度，此约束多模态问题集不包含等式约束
% problem.func_num ： 目标函数编号
% problem.dim ： 决策变量维度
% problem.func ： 目标函数句柄，调用形式为[f,g,h]=problem.func(X),其中f,g,h 分别为决策变量X的目标函数值、不等式约束函数值、等式约束函数值。
% problem.max_fes ： 目标函数最大评估次数
% problem.lower_bound ： 决策变量下界向量，维度为problem.dim
% problem.upper_bound ： 决策变量上界向量，维度为problem.dim
% problem.radius ： 判断全局最优变量是否重复半径,距离计算形式为欧式距离
func=problem.func;
Dim=problem.dim;
Max_Gen=problem.max_fes;
xmin=problem.lower_bound(1);
xmax=problem.upper_bound(1);
func_num=problem.func_num;
%binomialni a exponencialni krizeni soutezi ale jen v jedne generaci
N_init=floor(60*sqrt(Dim));
N_min = floor(N_init/2);
ps=N_init;
p=0.11;
max_velikost_archivu=round(ps*2.6);

 maxiter=Max_Gen;
 evals=ps;
 D=Dim;
 H=6;

 h=4;
 n0=2;
 delta=1/(5*h);
 ni=zeros(1,h)+n0;

 Xmin=repmat(xmin,1,D);
 Xmax=repmat(xmax,1,D);
 Xmin=repmat(Xmin,ps,1);
 Xmax=repmat(Xmax,ps,1);
%  
 pos=Xmin+(Xmax-Xmin).*rand(ps,D);
 P=zeros(ps,D+2);
 P(:,1:D)=pos;
 [P(:,D+1),gval,hval]=func(pos);
P(:,D+2) = sum_vio(gval,hval,problem.epsim);
 
 MFpbin=.5*ones(1,H);
 MFpexp=.5*ones(1,H);
 MCRpbin=.5*ones(1,H);%neni zde CR ale pm
 MCRpexp=.5*ones(1,H);
 MFprlbin=.5*ones(1,H);
 MFprlexp=.5*ones(1,H);
 MCRprlbin=.5*ones(1,H);%neni zde CR ale pm
 MCRprlexp=.5*ones(1,H);
 %pro ulozeni prumernych hodnot v pameti (vsechny MCR a vsechny MF)
 %pro ulozeni Fmin-Fmax v 10 etapach
  
 kpbin=1;
 kpexp=1;
 kprlbin=1;
 kprlexp=1;
 
 velarchivu=0;
 A=[];
 nspecies=10;
 while (evals<maxiter) 
    Fpoleexp=-1*ones(1,ps);
    CRpole=-1*ones(1,ps);
    CRpoleexp=-1*ones(1,ps);
    Fpolerl=-1*ones(1,ps);
    Fpolerlexp=-1*ones(1,ps);
    CRpolerl=-1*ones(1,ps);
    CRpolerlexp=-1*ones(1,ps);
    
    strategie=zeros(1,ps);
    
    SCRpbin=[];SFpbin=[];
    SCRpexp=[];SFpexp=[];
    SCRprlbin=[];SFprlbin=[];
    SCRprlexp=[];SFprlexp=[];
    uspesnychpbin=0;
    uspesnychpexp=0;
    uspesnychprlbin=0;
    uspesnychprlexp=0;
    

    deltafcepbin=-1*ones(1,ps);
    deltafcepexp=-1*ones(1,ps);
    deltafceprlbin=-1*ones(1,ps);
    deltafceprlexp=-1*ones(1,ps);
    
    species = getSpecies(P(:,1:D),P(:,D+1),P(:,D+2),nspecies);
    Q=zeros(ps,D+2);
    for i=1:ps  %VYTVORENI DALSI GENERACE
        [hh,p_min]=roulete(ni);
        if p_min<delta
            ni=zeros(1,h)+n0;
        end  %reset
        r=randi(H) ;%        r=1+fix(H*rand(1)); 

        sameSpecies = find(species==species(i)); 
        for try_num = 1:4
            switch hh 
                case 1 %(CURRENTTORAND/BIN)
                    strategie(1,i)=1; 
                    if MCRpbin(1,r)==-1
                        CR=0;
                    else
                        CR=MCRpbin(1,r)+ sqrt(0.1)*randn(1);
                    end
                    if CR>1
                        CR=1;
                    else if CR<0
                            CR=0;
                    end
                    end
                    F=-1;
                    while F<=0
                        F=rand*pi-pi/2;
                        F=0.1 * tan(F) + MFpbin(1,r);
                    end
                    if F>1 || isnan(F)
                        F=1;
                    end
                    %             p = pmin+ (0.2-pmin) * rand;
                    %ppoc=round(p*ps);
                    ppoc=round(p*nspecies );
                    if ppoc==0
                        ppoc=1;
                    end
                    Fpole(1,i)=F;
                    CRpole(1,i)=CR;

                    %y=currenttopbestbin_izrc_cons(A,velarchivu,P(:,1:D),P(:,D+1),P(:,D+2),ppoc,F,CR,i,xmin,xmax);
                    y=currenttopbestbin_izrc_cons(A,velarchivu,P(sameSpecies,1:D),P(sameSpecies,D+1),P(sameSpecies,D+2),ppoc,F,CR,find(sameSpecies==i),xmin,xmax);
                    %poskon(i,:)=y;
                    Q(i,1:D) = y;
                    [Q(i,D+1),gval,hval] = func(y);
                    Q(i,D+2) = sum_vio(gval,hval,problem.epsim);

                case 2  %(CURRENTTORAND/EXP)
                    strategie(1,i)=2;
                    if MCRpexp(1,r)==-1
                        CR=0;
                    else
                        CR=MCRpexp(1,r)+ sqrt(0.1)*randn(1);
                    end
                    if CR>1
                        CR=1;
                    else if CR<0
                            CR=0;
                    end
                    end
                    F=-1;
                    while F<=0
                        F=rand*pi-pi/2;
                        F=0.1 * tan(F) + MFpexp(1,r);
                    end
                    if F>1
                        F=1;
                    end
                    %             p = pmin+ (0.2-pmin) * rand;
                    %ppoc=round(p*ps);
                    ppoc=round(p*nspecies );
                    if ppoc==0
                        ppoc=1;
                    end
                    Fpoleexp(1,i)=F;
                    CRpoleexp(1,i)=CR;
                    %y=currenttopbestexp_izrc_cons(A,velarchivu,P(:,1:D),P(:,D+1),P(:,D+2),ppoc,F,CR,i,xmin,xmax);
                    y=currenttopbestexp_izrc_cons(A,velarchivu,P(sameSpecies,1:D),P(sameSpecies,D+1),P(sameSpecies,D+2),ppoc,F,CR,find(sameSpecies==i),xmin,xmax);
                    %poskon(i,:)=y;
                    Q(i,1:D) = y;
                    [Q(i,D+1),gval,hval] = func(y);
                    Q(i,D+2) = sum_vio(gval,hval,problem.epsim);

                case 3  %(RANDRL/BIN)
                    strategie(1,i)=3;
                    if MCRprlbin(1,r)==-1
                        CR=0;
                    else
                        CR=MCRprlbin(1,r)+ sqrt(0.1)*randn(1);
                    end
                    if CR>1
                        CR=1;
                    else if CR<0
                            CR=0;
                    end
                    end
                    F=-1;
                    while F<=0
                        F=rand*pi-pi/2;
                        F=0.1 * tan(F) + MFprlbin(1,r);
                    end
                    if F>1
                        F=1;
                    end


                    Fpolerl(1,i)=F;
                    CRpolerl(1,i)=CR;
                    y=derand_RLe_cons(P(:,1:D),P(:,D+1),P(:,D+2),F,CR,i,species);
                    %poskon(i,:)=zrcad(y,xmin,xmax);
                    Q(i,1:D) = y;
                    [Q(i,D+1),gval,hval] = func(y);
                    Q(i,D+2) = sum_vio(gval,hval,problem.epsim);

                case 4  %(RANDRL/EXP)
                    strategie(1,i)=4;
                    if MCRprlexp(1,r)==-1
                        CR=0;
                    else
                        CR=MCRprlexp(1,r)+ sqrt(0.1)*randn(1);
                    end
                    if CR>1
                        CR=1;
                    else if CR<0
                            CR=0;
                    end
                    end
                    F=-1;
                    while F<=0
                        F=rand*pi-pi/2;
                        F=0.1 * tan(F) + MFprlexp(1,r);
                    end
                    if F>1
                        F=1;
                    end
                    Fpolerlexp(1,i)=F;
                    CRpolerlexp(1,i)=CR;
                    y=derandexp_RLe_cons(P(:,1:D),P(:,D+1),P(:,D+2),F,CR,i,species);
                    %poskon(i,:)=zrcad(y,xmin,xmax);
                    Q(i,1:D) = y;
                    [Q(i,D+1),gval,hval] = func(y);
                    Q(i,D+2) = sum_vio(gval,hval,problem.epsim);

            end
            if P(i,D+1)==Q(i,D+1) && P(i,D+2)==Q(i,D+2)
                hh = mod(hh,4)+1;
            else
                break
            end
        end

    end
    % zjisteni, jak jsou na tom prvky Q
    isImprove=zeros(1,ps); 
    for i=1:ps
        if  Q(i,D+2)==0 && P(i,D+2)==0
            if Q(i,D+1)< P(i,D+1)
                % nahrad - y je uspesny
                isImprove(i)=1;
            end
        elseif Q(i,D+2) < P(i,D+2)
            % nahrad
            isImprove(i)=1;
        end
    end
    for i=1:ps
       if isImprove(i)==1 
            switch  strategie(1,i) 
                case 1
                    if Q(i,D+2)==0 && P(i,D+2)==0
                        deltafcepbin(1,i)=P(i,D+1)-Q(i,D+1);
                    else
                        deltafcepbin(1,i)=P(i,D+2)-Q(i,D+2);
                    end
                    uspesnychpbin=uspesnychpbin+1;
                    SCRpbin=[SCRpbin,CRpole(1,i)];
                    SFpbin=[SFpbin,Fpole(1,i)];
                case 2
                    if Q(i,D+2)==0 && P(i,D+2)==0
                        deltafcepexp(1,i)=P(i,D+1)-Q(i,D+1);
                    else
                        deltafcepexp(1,i)=P(i,D+2)-Q(i,D+2);
                    end
                    uspesnychpexp=uspesnychpexp+1;
                    SCRpexp=[SCRpexp,CRpoleexp(1,i)];
                    SFpexp=[SFpexp,Fpoleexp(1,i)];
                case 3 
                    if Q(i,D+2)==0 && P(i,D+2)==0
                        deltafceprlbin(1,i)=P(i,D+1)-Q(i,D+1);
                    else
                        deltafceprlbin(1,i)=P(i,D+2)-Q(i,D+2);
                    end
                    uspesnychprlbin=uspesnychprlbin+1;
                    SCRprlbin=[SCRprlbin,CRpolerl(1,i)];
                    SFprlbin=[SFprlbin,Fpolerl(1,i)];
                    
                case 4
                    if Q(i,D+2)==0 && P(i,D+2)==0
                        deltafceprlexp(1,i)=P(i,D+1)-Q(i,D+1);
                    else
                        deltafceprlexp(1,i)=P(i,D+2)-Q(i,D+2);
                    end
                    uspesnychprlexp=uspesnychprlexp+1;
                    SCRprlexp=[SCRprlexp,CRpolerlexp(1,i)];
                    SFprlexp=[SFprlexp,Fpolerlexp(1,i)];
            end
            if velarchivu < max_velikost_archivu
                A=[A;P(i,1:D)];
                velarchivu=velarchivu+1;
            else
                ktere=randi(velarchivu);
                A(ktere,:)=P(i,1:D);
            end
            P(i,:)=Q(i,:);
            ni(strategie(1,i))=ni(strategie(1,i))+1;         % zmena prsti qi 
       end
    end
    
    if uspesnychpbin>0 
        platne=find(deltafcepbin~=-1);
        delty=deltafcepbin(1,platne);
        suma=sum(delty);
        vahyw=1/suma*delty;
        mSCRpbin=max(SCRpbin);
        if MCRpbin(1,kpbin)==-1  ||  mSCRpbin==0
            MCRpbin(1,kpbin)=-1;
        else    
            MCRpbin(1,kpbin)=sum(vahyw.*SCRpbin);
        end
        meanSFpomjm=vahyw.*SFpbin;
        meanSFpomci=meanSFpomjm.*SFpbin;
        MFpbin(1,kpbin)=sum(meanSFpomci)/sum(meanSFpomjm);
        kpbin=kpbin+1;
        if kpbin>H
            kpbin=1;
        end
    end
    if uspesnychpexp>0
        platne=find(deltafcepexp~=-1);
        delty=deltafcepexp(1,platne);
        suma=sum(delty);
        vahyw=1/suma*delty; 
        mSCRpexp=max(SCRpexp);
        if MCRpexp(1,kpexp)==-1  ||  mSCRpexp==0
            MCRpexp(1,kpexp)=-1;
        else    
            MCRpexp(1,kpexp)=sum(vahyw.*SCRpexp);
        end
        meanSFpomjm=vahyw.*SFpexp;
        meanSFpomci=meanSFpomjm.*SFpexp;
        MFpexp(1,kpexp)=sum(meanSFpomci)/sum(meanSFpomjm);
        kpexp=kpexp+1;
        if kpexp>H
            kpexp=1;
        end
    end
    if uspesnychprlbin>0
        platne=find(deltafceprlbin~=-1);
        delty=deltafceprlbin(1,platne);
        suma=sum(delty);
        vahyw=1/suma*delty;
        mSCRprlbin=max(SCRprlbin);
        if MCRprlbin(1,kprlbin)==-1  || mSCRprlbin==0
            MCRprlbin(1,kprlbin)=-1;
        else    
            MCRprlbin(1,kprlbin)=sum(vahyw.*SCRprlbin);
        end
        meanSFpomjm=vahyw.*SFprlbin;
        meanSFpomci=meanSFpomjm.*SFprlbin;
        MFprlbin(1,kprlbin)=sum(meanSFpomci)/sum(meanSFpomjm);
        kprlbin=kprlbin+1;
        if kprlbin>H
            kprlbin=1;
        end
    end

    if uspesnychprlexp>0
        platne=find(deltafceprlexp~=-1);
        delty=deltafceprlexp(1,platne);
        suma=sum(delty);
        vahyw=1/suma*delty;
        mSCRprlexp=max(SCRprlexp);
        if MCRprlexp(1,kprlexp)==-1  ||  mSCRprlexp==0
            MCRprlexp(1,kprlexp)=-1;
        else    
            MCRprlexp(1,kprlexp)=sum(vahyw.*SCRprlexp);
        end
        meanSFpomjm=vahyw.*SFprlexp;
        meanSFpomci=meanSFpomjm.*SFprlexp;
        MFprlexp(1,kprlexp)=sum(meanSFpomci)/sum(meanSFpomjm);
        kprlexp=kprlexp+1;
        if kprlexp>H
            kprlexp=1;
        end
    end
    
    evals=evals+ps;
    
    ps_minule=ps;
    ps=round(((N_min-N_init)/maxiter)*evals+N_init);
    if ps<ps_minule
        P=sortrows(P,D+1);
        P=sortrows(P,D+2);
       %minimalizuju violation ale stejne tridim i podle fmin
        P=P(1:ps,:);
        max_velikost_archivu=round(ps*2.6);
        while velarchivu > max_velikost_archivu
            index_v_arch=randi(velarchivu);
            A(index_v_arch,:)=[];
            velarchivu=velarchivu-1;
        end
    end

end

population = P(:,1:D);
end


function result=keep_range(y,xi,a,b)
delka=length(y);
for i=1:delka
    if (y(i)<a)||(y(i)>b)
		if y(i)>b
		    y(i)=(b+xi(1,i))/2;
		elseif y(i)<a
		    y(i)=(a+xi(1,i))/2;
		end
    end
end
result=y;
end
function [species] = getSpecies(population,fitness,conV,nSpecies)
NP = size(population,1);
[~,rank] = sort(fitness + 1e100*conV);
species = zeros(1,NP);
speciesNum=floor(NP/nSpecies);
for i = 1:speciesNum
    besti = rank(find(~species(rank),1,'first'));
    species(besti) = i;
    for j = 2:nSpecies
        nn = getNN(population(besti,:),population,species);
        if nn == 0 
            break
        end
        species(nn) = i;
    end
end
species(~species) = speciesNum;
end
function nn = getNN(x1,pop,species)
[m,~] = size(pop);
minDis = inf;
nn = 0;
for i = 1:m
    dist = norm(x1-pop(i,:),2);
    if dist < minDis && ~species(i)
        minDis = dist;
        nn = i;
    end
    
end
if nn == 0
    pause
end
end
function y=derandexp_RLe_cons(P,hodf,hodviol,F,CR,expt,species)
N=length(P(:,1));
d=length(P(1,:));
% prd1=size(P)
% prd=expt(1)
y=P(expt(1),1:d);
%vyb=nahvyb_expt(N,3,expt);	% three random points without expt
pool=find(species==species(expt));
pool(pool==expt)=[];
vyb=pool(randperm(length(pool),3));
r123=P(vyb,:);
hodf123=hodf(vyb);
hodviol123=hodviol(vyb);

trivybrane=[r123 hodf123 hodviol123];
trivybrane=sortrows(trivybrane,d+1);
trivybrane=sortrows(trivybrane,d+2);

r1=trivybrane(1,1:d);
% if rand  < 0.5
%     r2=trivybrane(2,1:d);
%     r3=trivybrane(3,1:d);
% else
%     r2=trivybrane(2,1:d);
%     r3=trivybrane(3,1:d);
% end
r2=trivybrane(2,1:d);
r3=trivybrane(3,1:d);
v=r1+F*(r2-r3);

L=1+fix(d*rand(1));  % starting position for crossover
change=L;
position=L;
while rand(1) < CR && length(change) < d
    position=position+1;
    if position <= d
        change(end+1)=position;
    else
        change(end+1)=mod(position,d);
    end
end
y(change)=v(change);
end
function y=derand_RLe_cons(P,hodf,hodviol,F,CR,expt,species)
N=length(P(:,1));
d=length(P(1,:));
% prd1=size(P)
% prd=expt(1)
y=P(expt(1),1:d);
pool=find(species==species(expt));
pool(pool==expt)=[];
%vyb=nahvyb_expt(N,3,expt);	% three random points without expt
vyb=pool(randperm(length(pool),3));
r123=P(vyb,:);
hodf123=hodf(vyb);
hodviol123=hodviol(vyb);

trivybrane=[r123 hodf123 hodviol123];
trivybrane=sortrows(trivybrane,d+1); 
trivybrane=sortrows(trivybrane,d+2); 

r1=trivybrane(1,1:d);
% if rand  < 0.5
%     r2=trivybrane(2,1:d);
%     r3=trivybrane(3,1:d);
% else
%     r2=trivybrane(2,1:d);
%     r3=trivybrane(3,1:d);
% end
r2=trivybrane(2,1:d);
r3=trivybrane(3,1:d);
v=r1+F*(r2-r3);

change=find(rand(1,d)<CR);
if isempty(change) % at least one element is changed
    change=1+fix(d*rand(1));
end
y(change)=v(change);
end
function y=currenttopbestexp_izrc_cons(AR,velarch,PO,hodf,hodviol,p,F,CR,expt,a,b)
N=length(PO(:,1));
d=length(PO(1,:));

pom=zeros(N,d+2);
pom(:,1:d)=PO;
pom(:,d+1)=hodf;
pom(:,d+2)=hodviol;

pom=sortrows(pom,d+1);
pom=sortrows(pom,d+2);

pbest=pom(1:p,1:d);
ktery=1+fix(p*rand(1));
xpbest=pbest(ktery,:);
% prd1=size(PO)
% prd=expt(1)
xi=PO(expt(1),1:d);
pool = [1:N];
pool(expt) = [];
vyb = pool(randi(length(pool)));
%vyb=nahvyb_expt(N,1,expt);
r1=PO(vyb,:);

expt=[expt,vyb];
pool = [1:N+velarch];
pool(expt) = [];
vyb = pool(randi(length(pool)));

%vyb=nahvyb_expt(N+velarch,1,expt);
sjed=[PO;AR];
r2=sjed(vyb,:);

v=xi+F*(xpbest-xi)+F*(r1-r2);

y=xi;
% change=find(rand(1,d)<CR);
% if isempty(change) % at least one element is changed
%     change=1+fix(d*rand(1));
% end
% y(change)=v(change);

L=1+fix(d*rand(1));  % starting position for crossover
change=L;
position=L;
while rand(1) < CR && length(change) < d
    position=position+1;
    if position <= d
        change(end+1)=position;
    else
        change(end+1)=mod(position,d);
    end
end
y(change)=v(change);
y=keep_range(y,xi,a,b);
end
function y=currenttopbestbin_izrc_cons(AR,velarch,PO,hodf,hodviol,p,F,CR,expt,a,b)
N=length(PO(:,1));
d=length(PO(1,:));

pom=zeros(N,d+2);
pom(:,1:d)=PO;
pom(:,d+1)=hodf;
pom(:,d+2)=hodviol;

pom=sortrows(pom,d+1);
pom=sortrows(pom,d+2);

pbest=pom(1:p,1:d);
ktery=1+fix(p*rand(1));
xpbest=pbest(ktery,:);
% prd1=size(PO)
% prd=expt(1)
xi=PO(expt(1),1:d);
pool = [1:N];
pool(expt) = [];
vyb = pool(randi(length(pool)));
r1=PO(vyb,:);
expt=[expt,vyb];

pool = [1:N+velarch];
pool(expt) = [];
vyb = pool(randi(length(pool)));
sjed=[PO;AR];
r2=sjed(vyb,:);

v=xi+F*(xpbest-xi)+F*(r1-r2);

y=xi;
change=find(rand(1,d)<CR);
if isempty(change) % at least one element is changed
    change=1+fix(d*rand(1));
end
y(change)=v(change);
y=keep_range(y,xi,a,b);
end
function [res, p_min]=roulete(cutpoints)
%
% returns an integer from [1, length(cutpoints)] with probability proportional
% to cutpoints(i)/ summa cutpoints
%
h =length(cutpoints);
ss=sum(cutpoints);
p_min=min(cutpoints)/ss;
cp(1)=cutpoints(1);
for i=2:h
    cp(i)=cp(i-1)+cutpoints(i);
end
cp=cp/ss;
res=1+fix(sum(cp<rand(1)));
end