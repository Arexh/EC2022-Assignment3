function [population] = fNSDE_LSHADE44(CurrentSummary, func_num)%
% CurrentSummary.Epsim : degree of ignoring equality constraints
% problem.func_num: index of objective function
% problem.dim : problem dimension
% problem.func : problem pointer, e.g. [f,g,h]=problem.func(X)
% problem.max_fes : max evaluation number
% problem.lower_bound : lower_bound, dim is problem.dim
% problem.upper_bound : upper_bound, dim is problem.dim
% problem.radius : radius to judge convergence
func=CurrentSummary.ObjectiveFunctions{1, func_num};
Dim=CurrentSummary.Dimensions(1, func_num);
Max_Gen=CurrentSummary.MaxFitnessEvaluations;
xmin=CurrentSummary.LowerBound{1, func_num}(1);
xmax=CurrentSummary.UpperBound{1, func_num}(1);
% Ninit for linearly population decreasing
N_init=floor(60*sqrt(Dim));
N_min = floor(N_init/2);
ps=N_init;
p=0.11;
max_velikost_archivu=round(ps*2.6);

 maxiter=Max_Gen;
 evals=ps+CurrentSummary.CurrentEvalutionTime;
 D=Dim;
 H=6; % historical circle memories

 h=4;
 n0=2;
 delta=1/(5*h);
 ni=zeros(1,h)+n0;

 Xmin=repmat(xmin,1,D);
 Xmax=repmat(xmax,1,D);
 Xmin=repmat(Xmin,ps,1);
 Xmax=repmat(Xmax,ps,1);
 % init population
 if isnan(CurrentSummary.PopulationForLSHADE)
    pos=Xmin+(Xmax-Xmin).*rand(ps,D);
 else
    pos=CurrentSummary.PopulationForLSHADE;
 end
 P=zeros(ps,D+2);
 P(:,1:D)=pos;
 [P(:,D+1),gval,hval]=func(pos);
P(:,D+2) = sum_vio(gval,hval,CurrentSummary.Epsim);
 
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
    
    % set all s_f and s_c empty
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
    for i=1:ps  % for each individual
        [hh,p_min]=roulete(ni); % competition of four strategies
        if p_min<delta % reset to starting values
            ni=zeros(1,h)+n0;
        end
        r=randi(H) ; % random selector for circular memory (store mean of f and cr)

        sameSpecies = find(species==species(i)); 
        for try_num = 1:4
            switch hh 
                case 1 %(CURRENTTORAND/BIN)
                    strategie(1,i)=1; 
                    if MCRpbin(1,r)==-1
                        CR=0;
                    else
                        % generate CR in N(MCR, 0.1)
                        CR=MCRpbin(1,r)+ sqrt(0.1)*randn(1);
                    end
                    % clip CR
                    if CR>1
                        CR=1;
                    else if CR<0
                     end
                    end
                    F=-1;
                    % generate F from Cauchy(MF, 0.1) until bigger than 0
                    while F<=0
                        F=rand*pi-pi/2;
                        F=0.1 * tan(F) + MFpbin(1,r);
                    end
                    % clip F
                    if F>1 || isnan(F)
                        F=1;
                    end
                    %             p = pmin+ (0.2-pmin) * rand;
                    %ppoc=round(p*ps);
                    % choose 100p% best points
                    ppoc=round(p*nspecies );
                    if ppoc==0
                        ppoc=1;
                    end
                    % put into Sf and Sc
                    Fpole(1,i)=F;
                    CRpole(1,i)=CR;

                    %y=currenttopbestbin_izrc_cons(A,velarchivu,P(:,1:D),P(:,D+1),P(:,D+2),ppoc,F,CR,i,xmin,xmax);
                    % generate mutant vector
                    y=currenttopbestbin_izrc_cons(A,velarchivu,P(sameSpecies,1:D),P(sameSpecies,D+1),P(sameSpecies,D+2),ppoc,F,CR,find(sameSpecies==i),xmin,xmax);
                    %poskon(i,:)=y;
                    % Q: result individual with fitness and violation
                    Q(i,1:D) = y;
                    [Q(i,D+1),gval,hval] = func(y);
                    Q(i,D+2) = sum_vio(gval,hval,CurrentSummary.Epsim);

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
                    Q(i,D+2) = sum_vio(gval,hval,CurrentSummary.Epsim);

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
                    Q(i,D+2) = sum_vio(gval,hval,CurrentSummary.Epsim);

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
                    Q(i,D+2) = sum_vio(gval,hval,CurrentSummary.Epsim);

            end
            % if result are the same, then increase strategy num by one
            if P(i,D+1)==Q(i,D+1) && P(i,D+2)==Q(i,D+2)
                hh = mod(hh,4)+1;
            else
                break
            end
        end

    end
    % ps: population size (dynamic adjusted)
    isImprove=zeros(1,ps); 
    for i=1:ps
        if  Q(i,D+2)==0 && P(i,D+2)==0
            if Q(i,D+1)< P(i,D+1)
                % Q has greater fitness without valiation
                isImprove(i)=1;
            end
        elseif Q(i,D+2) < P(i,D+2)
            % Q has less violation
            isImprove(i)=1;
        end
    end
    for i=1:ps
       if isImprove(i)==1 
            % if improve, then store difference and Sf, Sc
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
            % if archive is not full, then put; else randomly override
            if velarchivu < max_velikost_archivu
                A=[A;P(i,1:D)];
                velarchivu=velarchivu+1;
            else
                ktere=randi(velarchivu);
                A(ktere,:)=P(i,1:D);
            end
            P(i,:)=Q(i,:);
            ni(strategie(1,i))=ni(strategie(1,i))+1; % increase the number of strategy's success by one
       end
    end
    
    % if strategy used, then update circle memories
    if uspesnychpbin>0 
        % find which individual improved
        platne=find(deltafcepbin~=-1);
        % improve degree
        delty=deltafcepbin(1,platne);
        % sum of improve degree
        suma=sum(delty);
        % normalized improve degree
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
    % if decrease population size, then select inferior one
    if ps<ps_minule
        P=sortrows(P,D+1);
        P=sortrows(P,D+2);
        % remove least one
        P=P(1:ps,:);
        % max archive size
        max_velikost_archivu=round(ps*2.6);
        % if archive size greater than max size, then randomly remove one
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
%% y: mutated individual
%% xi: origin individual
%% a: lower bound
%% b: upper bound
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
[~,rank] = sort(fitness + 1e100*conV); % conv: violation, add penalty
species = zeros(1,NP);
speciesNum=floor(NP/nSpecies);
for i = 1:speciesNum
    besti = rank(find(~species(rank),1,'first')); % find first non-species element with highest score
    species(besti) = i;
    for j = 2:nSpecies
        nn = getNN(population(besti,:),population,species); % get a non-species individual with minimum distance
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

% exp style
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
%%
%% P: individuals
%% hodf: fitness
%% hodviol: violation
%% p: first p% species
%% F: scale parameter
%% CR: probability parameter
%% i: ??
%% xmin, xmax: lower bound, upper bound
%%
N=length(P(:,1)); % population size
d=length(P(1,:)); % dimension
% prd1=size(P)
% prd=expt(1)
y=P(expt(1),1:d);
pool=find(species==species(expt));
pool(pool==expt)=[];
%vyb=nahvyb_expt(N,3,expt);	% three random points without expt
vyb=pool(randperm(length(pool),3)); % random choose three point except slected one
r123=P(vyb,:); % three individuals
hodf123=hodf(vyb); % three fitnesses
hodviol123=hodviol(vyb); % three violations

% combine and sort according to fitness and violation
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

% bin style
change=find(rand(1,d)<CR);
if isempty(change) % at least one element is changed
    change=1+fix(d*rand(1));
end
y(change)=v(change);
end
function y=currenttopbestexp_izrc_cons(AR,velarch,PO,hodf,hodviol,p,F,CR,expt,a,b)
%%
%% A: archive
%% velarch: archive length
%% P0: individuals
%% hodf: fitness
%% hodviol: violation
%% p: first p% species
%% F: scale parameter
%% CR: probability parameter
%% i: ??
%% xmin, xmax: lower bound, upper bound
%%
N=length(PO(:,1)); % population size
d=length(PO(1,:)); % dimension

pom=zeros(N,d+2); % individual, fitness, violation
pom(:,1:d)=PO;
pom(:,d+1)=hodf;
pom(:,d+2)=hodviol;

% sort according to fitness and violation
pom=sortrows(pom,d+1);
pom=sortrows(pom,d+2);

% current best individual: randomly choosen from 100p%
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

% select dimension to mutate, according to the value of CR
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
%%
%% A: archive
%% velarch: archive length
%% P0: individuals
%% hodf: fitness
%% hodviol: violation
%% p: first p% species
%% F: scale parameter
%% CR: probability parameter
%% expt: selected individual
%% xmin, xmax: lower bound, upper bound
%%
N=length(PO(:,1)); % population size
d=length(PO(1,:)); % dimension

pom=zeros(N,d+2); % individual, fitness, violation
pom(:,1:d)=PO;
pom(:,d+1)=hodf;
pom(:,d+2)=hodviol;

% sort according to fitness and violation
pom=sortrows(pom,d+1);
pom=sortrows(pom,d+2);

% current best individual: randomly choosen from 100p%
pbest=pom(1:p,1:d);
ktery=1+fix(p*rand(1));
xpbest=pbest(ktery,:);
% prd1=size(PO)
% prd=expt(1)
% current selected individual
xi=PO(expt(1),1:d);
pool = [1:N];
pool(expt) = [];
% r1: randomly choose an individual
vyb = pool(randi(length(pool)));
r1=PO(vyb,:);
expt=[expt,vyb];

% r2: randomly choose an individual from P union Archive
pool = [1:N+velarch];
pool(expt) = [];
vyb = pool(randi(length(pool)));
sjed=[PO;AR];
r2=sjed(vyb,:);

% calculate mutant vector
v=xi+F*(xpbest-xi)+F*(r1-r2);

% select dimension to mutate, according to the value of CR (bin)
y=xi;
change=find(rand(1,d)<CR);
if isempty(change) % if non change, then randomly choose
    change=1+fix(d*rand(1));
end
y(change)=v(change);
y=keep_range(y,xi,a,b);
end
function [res, p_min]=roulete(cutpoints)
%
% returns an integer from [1, length(cutpoints)] with probability proportional
% to cutpoints(i)/ summa cutpoints
% res: selected num, p_min: min probability
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