function [ind]=MGCScaleVerify(V)
% An auxiliary function to verify and estimate the MGC optimal scale
% cc=mean(mean(pAll(2:end,2:end)<0.05));
% if cc>0.05
%     ind=find(pAll==min(min(pAll)),1,'last');
% else
%     ind=1;
% end

VN=V(2:end,2:end);
k=Verify(VN)+1;
l=Verify(VN')+1;
% if (mean(VN(VN<1))<0.1)
% %      [mean(VN(VN<1)),std(VN(VN<1))]
%     k=2:size(V,1);
%     l=2:size(V,2);
% else
%     [k,l]=size(V);
% end
ind=find(V==min(min(V(k,l))),1,'last');

function k=Verify(VN)
thres=0.15;
[m,n]=size(VN);
rowMean=median(VN,2);

% [mean(rowMean), std(rowMean),min(rowMean)]
k=m;

if median(rowMean)<thres %|| min(rowMean)<=0.01
    k=1:m;
end
% 
% 
% figure
% plot(1:m,rowMean<0.05);
% lim=4;
% k=m;
% for l=1:lim
%     len=ceil(m/l);
%     if lim>1 && len*m<max(1/lim*n*m,300)
%         break;
%     end
%     for j=1:l
%         kt=(j-1)*len+1:min(j*len,m);
%         if mean(rowMean(kt))<thres
%             k=kt;
%             break;
%         end
%     end
% end
    

function k=VerifyRow(tmp)
thres1=2.5;
thres2=0.5;
stdN=std(tmp(tmp>-10));
[m,n]=size(tmp);
tmp=tmp-thres1*stdN;

t=[];
for i=1:m;
    cE=find(tmp(i,:)<=0);
    cS=[0 cE];
    cE=[cE m+1];
    c=max(cE-cS)-1;
    if c/n>thres2
        t=[t,i];
    end
end

k=[];
if (length(t)>1)
    if t(1)+1==t(2)
        k=[k t(1)];
    end
    for i=2:length(t)-1
        if (t(i)-1==t(i-1) && (t(i)+1==t(i+1)));
            k=[k t(i)];
        end
    end
    if t(length(t)-1)+1==t(length(t))
        k=[k t(end)];
    end
end

if (length(k)/n<0.05)
    k=m;
end

function k=VerifyRow2(tmp)
thres1=2;
thres2=0.5;
[m,n]=size(tmp);
% 
% t1=mean(tmp>thres1,2);
% if max(t1)<thres2  || sum(t1>thres2)<0.02*m
%     k=m;
% else
%     k=find(t1>thres2);
% end

t=[];
for i=1:m;
    cE=find(tmp(i,:)<thres1);
    cS=[0 cE];
    cE=[cE m+1];
    c=max(cE-cS)-1;
    if c/n>thres2
        t=[t,i];
    end
end

k=[];
if (length(t)>1)
    if t(1)+1==t(2)
        k=[k t(1)];
    end
    for i=2:length(t)-1
        if (t(i)-1==t(i-1) && (t(i)+1==t(i+1)));
            k=[k t(i)];
        end
    end
    if t(length(t)-1)+1==t(length(t))
        k=[k t(end)];
    end
end

if (length(k)/n<0.02)
    k=m;
end