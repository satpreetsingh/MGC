function [power1, power2, power3, power4]=CorrIndTestDim(type,n,dim,lim,rep, noise,option)
% Author: Cencheng Shen
% Independence Tests for identifying dependency, returning empirical testing power with respect to increasing dimension at a fixed sample size.
% The output are the powers of local original dCorr, local modified
% dCorr, HHG, and Mantel test.
%
% Parameters:
% type specifies the type of distribution,
% n is the sample size, dim is the dimension,
% lim specifies the number of intervals in the sample size,
% rep specifies the number of MC-replicates,
% noise specifies the noise level, by default 0,
% option specifies whether each test statistic is calculated or not.
if nargin<6
    noise=0; % Default noise level
end
if nargin<7
    option=[1,1,1,1]; % Default option
end
K=n;
alpha=0.05; % Type 1 error level

if lim==0
    dimRange=dim; % Test at dim only
    lim=1;
else
    dimRange=ceil(dim/lim):ceil(dim/lim):dim; % Test using dimension choices at the interval of ceil(dim/lim).
end

% Intermediate results
dCor1N=zeros(K,K,rep);dCor2N=zeros(K,K,rep);dCor3N=zeros(1,rep);dCor4N=zeros(1,rep);
dCor1A=zeros(K,K,rep);dCor2A=zeros(K,K,rep);dCor3A=zeros(1,rep);dCor4A=zeros(1,rep);

% Output
power1=zeros(K,K,lim);power2=zeros(K,K,lim);power3=zeros(1,lim);power4=zeros(1,lim);% Powers for dCorr, mdCorr, HHG, and Mantel

% Iterate through all dimension choices
for i=1:lim
    d=dimRange(i);
    % First generate null distribution, i.e., X and Y are independent
    % and estimate the distribution of the test statistics under the null
    for r=1:rep
        % Generate independent sample data
        [x,y]=CorrSampleGenerator(type,n,d,0, noise);
        % Form the distance matrix and calculate all test statistics under the null
        C=squareform(pdist(x));
        P=squareform(pdist(y));
        disRank=[disToRanks(C) disToRanks(P)];
        if option(1)~=0
            dCor1N(:,:,r)=localDCorr(C,P,0,disRank);
        end
        if option(2)~=0
            dCor2N(:,:,r)=localDCorr(C,P,1,disRank);
        end
        if option(3)~=0
            dCor3N(r)=HHG(C,P);
        end
        if option(4)~=0
            dCor4N(r)=Mantel(C,P);
        end
    end
    
    % Then generate the alternative distribution, i.e., X and Y are dependent,
    % and estimate the distribution of the test statistics under the alternative
    for r=1:rep
        % Generate dependent sample data
        [x,y]=CorrSampleGenerator(type,n,d,1, noise);
        % Form the distance matrix and calculate all test statistics under the alternative
        C=squareform(pdist(x));
        P=squareform(pdist(y));
        disRank=[disToRanks(C) disToRanks(P)];
        if option(1)~=0
            dCor1A(:,:,r)=localDCorr(C,P,0,disRank);
        end
        if option(2)~=0
            dCor2A(:,:,r)=localDCorr(C,P,1,disRank);
        end
        if option(3)~=0
            dCor3A(r)=HHG(C,P);
        end
        if option(4)~=0
            dCor4A(r)=Mantel(C,P);
        end
    end
    
    % Based on the emprical test statistics under the null and the alternative,
    % calculate the emprical powers at type 1 error level alpha=0.05
    for k=1:K
        for k2=1:K;
            dCorT=sort(dCor1N(k,k2,:),'descend');
            cut1=dCorT(ceil(rep*alpha));
            power1(k,k2,i)=mean(dCor1A(k,k2,:)>cut1);
            
            dCorT=sort(dCor2N(k,k2,:),'descend');
            cut2=dCorT(ceil(rep*alpha));
            power2(k,k2,i)=mean(dCor2A(k,k2,:)>cut2);
        end
    end
    dCorT=sort(dCor3N,'descend');
    cut3=dCorT(ceil(rep*alpha));
    power3(i)=mean(dCor3A>cut3);
    dCorT=sort(dCor4N,'descend');
    cut4=dCorT(ceil(rep*alpha));
    power4(i)=mean(dCor4A>cut4);
end

% Save the results
filename=strcat('CorrIndTestDimType',num2str(type),'N',num2str(n),'Dim');
%save(filename,'power1','power2','power3','power4','type','n','dimRange','rep','lim','dim','noise','option');
save(filename,'power1','power2','power3','power4','type','n','dimRange','rep','lim','dim','noise','option','dCor2A','dCor2N','dCor1A','dCor1N');

% %% Display and save picture. By default do not display.
% % Plot figure
% for i=1:length(dimRange)
%     power1M(i)=max(max(power1(:,:,i)));
%     power2M(i)=max(max(power2(:,:,i)));
% end
% plot(dimRange, power2M,'ro-',dimRange,power1M,'bx-',dimRange,power3,'g.-',dimRange,power4,'c.-','LineWidth',2);
% hl=legend('Local Modified Distance Correlation','Local Original Distance Correlation','HHG','Mantel','Location','SouthEast');
% 
% % Figure title/labels
% xlabel('Dimension');
% ylabel('Empirical Testing Power');
% xlim([dimRange(1) dimRange(end)]);
% ylim([0 1]);
% %     titleStr = strcat('Independence Test for ', titlechar,' at n=', num2str(n), ' up To m= ',num2str(dim));
% %     title(titleStr);
% %     saveas(gcf,filename,'jpeg');