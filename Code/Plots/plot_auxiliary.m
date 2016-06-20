function []=plot_auxiliary(type,pre1)%,pre2)

% type=6;n=100;dim=1;noise=1;pre1='../../Data/';
% CorrSimPlotsA(type,n,dim,noise,pre1);
% Used to generate figure A in the files

if nargin<1
    type=13;
end
if nargin<2
    pre1='../../Data/Results/'; % The folder to locate data
end
% if nargin<2
%     pre2='../../Draft/Figures/FigReal'; % The folder to save figures
% end
option=2;
n=100;
dim=1;
noise=1;

cmap=zeros(3,3);
gr = [0.5,0.5,0.5];
ma = [1,0,1];
% cy = [0,1,1];
cmap(1,:) = gr;
cmap(2,:) = gr;
% cmap(3,:) = cy;
map1=cmap;
map2 = brewermap(128,'BuGn'); % brewmap
set(groot,'defaultAxesColorOrder',map1);

% Generate data
[x, y]=CorrSampleGenerator(type,n,dim,1, noise);
[x1, y1]=CorrSampleGenerator(type,10*n,dim,1, 0); % Plot 10*n points without noise to highlight the underlying dependency
% A1: scatter plot
figure
plot(x,y,'.',x1,y1,'k.','MarkerSize',30);
xlabel('X','FontSize',25)
ylabel('Y','FontSize',25,'Rotation',0,'position',[-1.3,-0.1]);
xlim([-1.2,1.2]);
ylim([-1.2,1.2]);
title('Scatter Plot of (X,Y)','FontSize',30)
set(gca,'XTick',[]); % Remove x axis ticks
set(gca,'YTick',[]); % Remove y axis ticks
% Get distance matrix
[x,ind]=sort(x,'ascend');
y=y(ind);
C=squareform(pdist(x));
D=squareform(pdist(y));
tA=localCorr(C,D,2);
rep=1000;
tN=zeros(n,n,rep);
for r=1:rep;
    per=randperm(n);
    tN(:,:,r)=localCorr(C,D(per,per),2);
end

% A2: heatmaps of the distance matrices
maxC=ceil(max(max([C,D]))*10)/10;
figure
imagesc(C');
colormap(map2)
caxis([0,maxC]);
h=colorbar('Ticks',[-1000,0,maxC]);
    set(h,'FontSize',16);
title('Pairwise Distances','FontSize',30)
set(gca,'XTick',[]); % Remove x axis ticks
set(gca,'YTick',[]); % Remove y axis ticks
%xlabel('\tilde{A}_{ij}=\|x_{i}-x_{j}\|_{2}','FontSize',25);
ylabel('$$\tilde{A}$$','FontSize',30,'Rotation',0,'position',[-5,50],'interpreter','latex');

%subplot(s,t,6)
figure
imagesc(D');
set(gca,'FontSize',16)
colormap(map2)
h=colorbar('Ticks',[-1000,0,maxC]);
    set(h,'FontSize',16);
caxis([0,maxC]);
% title('Distance Heatmap of Y','FontSize',16)
set(gca,'XTick',[]); % Remove x axis ticks
set(gca,'YTick',[]); % Remove y axis ticks
%xlabel('\tilde{B}_{ij}=\|y_{i}-y_{j}\|_{2}','FontSize',25);
ylabel('$$\tilde{B}$$','FontSize',30,'Rotation',0,'position',[-5,50],'interpreter','latex');

% A3: heatmaps of the doubly centered distance matrices
for option=1:1
    RC=disToRanks(C);
    RD=disToRanks(D);
    if option==3;
        A=sum(sum(C))/n/(n-1);
        B=sum(sum(D))/n/(n-1);
        A=C-A;
        B=D-B;
        for j=1:n
            A(j,j)=0;
            B(j,j)=0;
        end
    else
        H=eye(n)-(1/n)*ones(n,n);
        A=H*C;
        B=D*H;
        % % For mcorr, further adjust the double centered matrices to remove high-dimensional bias
        if option==2
            A=A-C/n;
            B=B-D/n;
            for j=1:n
                A(j,j)=0;
                B(j,j)=0;
            end
        end
    end
    %global stat
    A=A-mean(mean(A));B=B-mean(mean(B));
    mcorrH=A.*B;
    %
    minC=floor(min(min([A,B]))*10)/10;maxC=ceil(max(max([A,B]))*10)/10;
    figure
    imagesc(A');
    colormap(map2)
    caxis([minC,maxC]);
    h=colorbar('Ticks',[-1000,minC,maxC]);
    set(h,'FontSize',16);
    %title('Normalized Distances','FontSize',30)
    set(gca,'XTick',[]); % Remove x axis ticks
    set(gca,'YTick',[]); % Remove y axis ticks
    %xlabel('A=H\tilde{A}H','FontSize',25);
    ylabel('$$A$$','FontSize',30,'Rotation',0,'position',[-5,50],'interpreter','latex');
    
    figure
    imagesc(B');
    set(gca,'FontSize',16)
    colormap(map2)
    caxis([minC,maxC]);
    h=colorbar('Ticks',[-1000,minC,maxC]);
    set(h,'FontSize',16);
    %title('Doubly-Centered Distance Heatmap of Y','FontSize',16)
    set(gca,'XTick',[]); % Remove x axis ticks
    set(gca,'YTick',[]); % Remove y axis ticks
    %xlabel('B=H\tilde{B}H','FontSize',25);
    ylabel('$$B$$','FontSize',30,'Rotation',0,'position',[-5,50],'interpreter','latex');
    
    % Local distance matrices
    if n~=100 || noise~=1
        CorrIndTest(type,n,1,1,0, 1000,noise,0.05,[1,0,0,0]);
    end
    filename=strcat(pre1,'CorrIndTestType',num2str(type),'N',num2str(n),'Dim1.mat');
    load(filename,'neighborhoods');
    neighbor=neighborhoods(1,end);
    l=ceil(neighbor/n);
    k=neighbor-n*(l-1);
    RC=(RC>k);
    RD=(RD>l);
    % ind=(dC.*dD==0);
    A(RC)=0;
    B(RD)=0;
    A=A-mean(mean(A));B=B-mean(mean(B));
    
    % A4: heatmaps of the local doubly centered distance matrices
    A(RC)=minC;
    B(RD)=minC;
    figure
    imagesc(A');
    colormap(map2)
    caxis([minC,maxC]);
    h=colorbar('Ticks',[-1000,minC,maxC]);
    set(h,'FontSize',16);
    %title('Local Normalized Distances','FontSize',30)
    %xlabel('A^{k^{*}}=','FontSize',25);
    title('$$A^{k^{*}}$$','FontSize',30,'interpreter','latex');
    set(gca,'XTick',[]); % Remove x axis ticks
    set(gca,'YTick',[]); % Remove y axis ticks
    
    figure
    imagesc(B');
    set(gca,'FontSize',16)
    colormap(map2)
    caxis([minC,maxC]);
    h=colorbar('Ticks',[-1000,minC,maxC]);
    set(h,'FontSize',16);
    %title('Local Doubly-Centered Distance Heatmap of Y','FontSize',16)
    title('$$B^{l^{*}}$$','FontSize',30,'interpreter','latex');
    set(gca,'XTick',[]); % Remove x axis ticks
    set(gca,'YTick',[]); % Remove y axis ticks
    
    % A4: heatmaps of the distance covariance entries
    figure
    MH=ceil(max(max(mcorrH(2:end,2:end)))*10)/10;
    mMH=floor(min(min(mcorrH(2:end,2:end)))*10)/10;
    imagesc(mcorrH');
    set(gca,'FontSize',16)
    colormap(map2)
    %h=colorbar;
    %set(h,'FontSize',16);
    caxis([mMH,MH]);
    h=colorbar('Ticks',[-1000,mMH,MH]);
    set(h,'FontSize',16);
    %ylabel('$$A^{k^{*}}.*B^{l^{*}}$$','FontSize',25,'Rotation',0,'position',[-5,50],'interpreter','latex');
    set(gca,'XTick',[]); % Remove x axis ticks
    set(gca,'YTick',[]); % Remove y axis ticks
    %title('Element-wise Product of','FontSize',30)
    title('$$A.*B$$','FontSize',30,'interpreter','latex');
    %title('Local Distance Covariance of (X, Y)','FontSize',16)
    
    % A4: heatmaps of the distance covariance entries
    figure
    mcorrH(RC)=0;
    mcorrH(RD)=0;
    MH=ceil(max(max(mcorrH(2:end,2:end)))*10)/10;
    imagesc(mcorrH');
    set(gca,'FontSize',16)
    colormap(map2)
    %h=colorbar;
    %set(h,'FontSize',16);
    caxis([0,MH]);
    h=colorbar('Ticks',[-1000,0,MH]);
    set(h,'FontSize',16);
    %ylabel('$$A^{k^{*}}.*B^{l^{*}}$$','FontSize',25,'Rotation',0,'position',[-5,50],'interpreter','latex');
    set(gca,'XTick',[]); % Remove x axis ticks
    set(gca,'YTick',[]); % Remove y axis ticks
    title('$$A^{k^{*}}.*B^{l^{*}}$$','FontSize',30,'interpreter','latex');
    %title('Element-wise Product of','FontSize',30)
    %title('Local Distance Covariance of (X, Y)','FontSize',16)
    
    figure
    filename=strcat(pre1,'CorrIndTestType',num2str(type),'N100Dim1.mat');
    load(filename)
    kmin=2;
    lim=length(power2);
    hold on
    ph=power2All(kmin:numRange(lim),kmin:numRange(lim),lim)';
%     nei=find(ph>0.99);
%     [k,l]=ind2sub(size(ph),nei);
    imagesc(ph);
    set(gca,'FontSize',16)
    set(gca,'YDir','normal')
    map2 = brewermap(128,'GnBu'); % brewmap
    cmap=zeros(100,3);
    cmap(1:98,:)=map2(1:98,:);
    cmap(99,:)=map2(127,:);
    cmap(100,:)=map2(128,:);
    colormap(cmap)
    caxis([0.5 1])
    xlabel('k','FontSize',25)
    ylabel('l','FontSize',25,'Rotation',0,'position',[-5,50]);
    xlim([1 99]);
    ylim([1 99]);
    h=colorbar('Ticks',[-1000,0.5,0.99]);
    set(h,'FontSize',16);
    
% %     imagesc(l,k,ph(k,l)*2);
    
    hold off
%     %set(h,'FontSize',16,'location','southoutside');
        set(gca,'XTick',[]); % Remove x axis ticks
        set(gca,'YTick',[]); % Remove y axis ticks
    title('Testing Powers','FontSize',30);
end