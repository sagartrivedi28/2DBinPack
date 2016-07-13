function [Fcor,Fsets,Fwafer] = DicePackingR4( Did,Ddimx,Ddimy,Dvol,Dreq,Gpara,ax)

%%%%%%%%%%%%% Tasks Left %%%%%%%%%%%%%%%%%%%%%
%{
1. As Per Dice Volume Optimize the reticle area & Dice count
2. Arrange shelves betterway: need to align same width/height dices
3. Conflict Graph Generation Algorithm: Need to consider 300nm adjacent cut
4. Graph Partition Algorithm: Need to consider the SameCut Dice

Dreq: SeparateGroup  ChipAroun   SameCut  Isolate-1mm   Manual/Auto-Repeat
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DidL = Did;
% Did = 1:length(Did);

IValue = 2000; % in Micrometer


Rmax = Gpara.Rmax;
Sline = Gpara.Sline;
Rno = Gpara.Rno;

Iso1mm = Dreq(:,4);

Ddimx = Ddimx+IValue*(Iso1mm~=0);
Ddimy = Ddimy+IValue*(Iso1mm~=0);

[NDdimy,ind1] = sort(Ddimy,'descend');
NDid = Did(ind1);
NDdimx = Ddimx(ind1);
NDvol = Dvol(ind1);
NDreq = Dreq(ind1,:);
N = length(NDid);
Maxset = N;

NIso1mm = Iso1mm(ind1);


for W = Rmax(1):-10^3:12000 %max(NDdimx)
    l=1;
    T_height=0;
	shelf.height = [];
	shelf.empty = W;
	shelf.Dinfo = [];
    shelf.level=[];
	Dcor = zeros(N,4);
    
    for n=1:N      
        
        Dflag=true;
        i=1;
        while Dflag
            if shelf(i).empty >= NDdimx(n)
                if shelf(i).empty==W
                    shelf(i).height = NDdimy(n);
                    shelf(i).level = T_height;
                    T_height = T_height+NDdimy(n);
                end;
                Dloc = W-shelf(i).empty;
                shelf(i).empty = shelf(i).empty-NDdimx(n);
                shelf(i).Dinfo = [shelf(i).Dinfo; NDid(n) NDdimx(n) Dloc (shelf(i).height-NDdimy(n))];  % ID, X-dimention, X-location, Height Leftover
                Dcor(NDid(n),:) = [Dloc,shelf(i).level,Dloc+NDdimx(n),shelf(i).level+NDdimy(n)];
                Dflag = false;
                
                if NIso1mm(n)~=0
                    Dcor(NDid(n),:) = [Dloc+IValue/2,shelf(i).level+IValue/2,Dloc+NDdimx(n)-IValue,shelf(i).level+NDdimy(n)-IValue];
                    
                    if (shelf(i).empty+NDdimx(n))~=W && Iso1mm(shelf(i).Dinfo(end-1,1))~=0
                        shelf(i).empty = shelf(i).empty+IValue;
                        Dcor(NDid(n),:) = [Dloc+IValue/2-IValue,shelf(i).level+IValue/2,Dloc+NDdimx(n)-2*IValue,shelf(i).level+NDdimy(n)-IValue];
                        temp = shelf(i).Dinfo(end-1);
                        shelf(i).Dinfo(end-1) = [temp(1) temp(2)-IValue/2 temp(3) temp(4)];
                        shelf(i).Dinfo(end) = [temp(1) temp(2)-IValue/2 temp(3)-IValue/2 temp(4)];
                    end;
                    
                    
                end;
               
            else
                if i<l
                    i=i+1;
                else
                    l=l+1;
                    i=i+1;
                    shelf(i).empty=W;
                end;
            end;
            
        end;
    end;
   
    for sh=1:length(shelf(1).Dinfo(:,1))
        if (shelf(1).Dinfo(sh,end) > shelf(end).height) && ((W-shelf(1).Dinfo(sh,3)) > (W-shelf(end).empty))
            
            shelf(end).Dinfo(:,3) = shelf(end).Dinfo(:,3) + shelf(1).Dinfo(sh,3);
            shelf(end).Dinfo(:,4) = shelf(end).Dinfo(:,4) + (shelf(1).Dinfo(sh,end)-shelf(end).height);
            shelf(end).level = shelf(1).height-shelf(1).Dinfo(sh,end);
            
            for s1 = 1:length(shelf(end).Dinfo(:,1))
                D1 = shelf(end).Dinfo(s1,1);                
                Dcor(D1,:) = [shelf(end).Dinfo(s1,3), shelf(end).level,...
                    shelf(end).Dinfo(s1,3) + shelf(end).Dinfo(s1,2),...
                    shelf(end).level+(shelf(end).height-shelf(end).Dinfo(s1,4))];                
            end;
            
            break;            
        end;
        
    end
    
       
    
    % Need to re-arrange Shelves to get maxima yield
    
    if T_height< Rmax(2)
        Cmat = Cgraph(Dcor,Dvol,N);
        [sets, Wvector] = CGpartition(Cmat,Dvol,N,Rno);
        if Maxset>length(Wvector)
            Maxset=length(Wvector);
            Fwafer = Wvector;
            Fshelf = shelf;
            Fcor = Dcor;
            FCmat = Cmat;
            Fsets = sets;
        end;
    end;
    shelf=[];

end;

Ddimx = Ddimx-IValue*(Iso1mm~=0);
Ddimy = Ddimy-IValue*(Iso1mm~=0);

Rshift = [max(Fcor(:,3))-min(Fcor(:,1)) max(Fcor(:,4))-min(Fcor(:,2))]/2;
axes(ax);
cla;
axis(1.1*[-Rmax(1)/2,Rmax(1)/2+1,-Rmax(2)/2-1,Rmax(2)/2+1]);
rectangle('Position',[-Rmax(1)/2,-Rmax(2)/2,Rmax(1),Rmax(2)],'LineWidth',2,'LineStyle','--','EdgeColor','r');
rectangle('Position',[-Rshift(1),-Rshift(2),2*Rshift(1),2*Rshift(2)],'LineWidth',2,'LineStyle','--');
SetsColor = hot(length(Fsets));

for l=1:length(Fsets)
    for i=1:length(Fsets{l})
        rectangle('Position',[Fcor(Fsets{l}(i),1)+(Sline(1)/2)-Rshift(1), Fcor(Fsets{l}(i),2)+(Sline(2)/2)-Rshift(2),Ddimx(Fsets{l}(i))-Sline(1),Ddimy(Fsets{l}(i))-Sline(2)],'LineWidth',1,'FaceColor','c');
        rectangle('Position',[Fcor(Fsets{l}(i),1)-Rshift(1),Fcor(Fsets{l}(i),2)-Rshift(2),Ddimx(Fsets{l}(i)),Ddimy(Fsets{l}(i))],'LineWidth',1,'LineStyle','--','EdgeColor','b');
        text(Fcor(Fsets{l}(i),1)-Rshift(1)+Ddimx(Fsets{l}(i))/2,Fcor(Fsets{l}(i),2)-Rshift(2)+Ddimy(Fsets{l}(i))/2,num2str(Fsets{l}(i)),'FontSize',8,'BackgroundColor',SetsColor(l,:));
    end;
end;
text(0,Rshift(2)+1000,['Detected Minima Cut-Sets: ' num2str(length(Fsets))],'FontSize',12);
end



% Conflict Graph Generation Algorithm: Need to consider 300nm adjacent cut
function Cmat = Cgraph(Dcor,Dvol,N)
Cmat = false(N);
for k1=1:N
    for k2=1:N
        if (Dvol(k2)~=0) && (Dvol(k1)~=0)
            if ((Dcor(k1,1) < Dcor(k2,1)) && (Dcor(k2,1) < Dcor(k1,3))) || ((Dcor(k1,1) < Dcor(k2,3)) && (Dcor(k2,3) < Dcor(k1,3))) || ...
                    ((Dcor(k1,2) < Dcor(k2,2)) && (Dcor(k2,2) < Dcor(k1,4))) || ((Dcor(k1,2) < Dcor(k2,4)) && (Dcor(k2,4) < Dcor(k1,4)))
                Cmat(k1,k2)=1;
            end;
        end;
    end;
end;
Cmat = Cmat | Cmat';
end

% Graph Partition Algorithm: Need to consider the SameCut Dice
function [Nsets, Wvector] = CGpartition(Cmat,Dvol,N,Rno)

Tvol = Dvol;
Vunit = min(Tvol(Tvol~=0));

sets=false(size(Cmat(:,1)));
% Tvol(temp(1))=0;

while sum(Tvol)
    temp = find(Tvol==min(Tvol(Tvol~=0)));
    Sflag = false;
    
    for l=1:size(sets,2) 
            if (~(sum(Cmat(:,temp(1)).*sets(:,l)) || sets(temp(1),l)) || Sflag)
                sets(temp(1),l)=true;
                Sflag=true;
            end;
    end;
    
    if Sflag==false
        sets = [sets false(size(Cmat(:,1)))];
        sets(temp(1),end) = true;
    end;
    
    Tvol(temp(1))=0;
end;

Tvol = Dvol;

while sum(Tvol)
    temp = find(Tvol==max(Tvol));
    
    for l=1:size(sets,2) 
            if ~(sum(Cmat(:,temp(1)).*sets(:,l)) || sets(temp(1),l))
                sets(temp(1),l)=true;                
            end;
    end;  
    
    Tvol(temp(1))=0;
end;
sets(Dvol==0,end)=true;

Nsets={};
for k=1:size(sets,2)
    Nsets{k}=find(sets(:,k))';
end;

Wvector = Wminimize(sets,Dvol,Rno);

end

function Wvector = Wminimize(sets,Dvol,Rno)

Ksets = double(sets);
Bsets = Ksets(1,:);
NDvol = Dvol(1);
l=1;
for r = 2:length(Rno)
    if (Rno(r-1)==Rno(r))
        Bsets(l,:) = Bsets(l,:)+Ksets(r,:);
        NDvol(l) = NDvol(l)+Dvol(r);
    else
        Bsets = [Bsets; Ksets(r,:)];
        NDvol = [NDvol;Dvol(r)];
        l=l+1;
    end;
    
end;

WIvector = zeros(length(sets(1,:)),1);

fun = @(Wvector) sum(abs(Bsets*ceil(Wvector)-NDvol)); %fun = @(Wvector) sum(ceil(Wvector));
A=-Bsets;
b=-NDvol;
Aeq=[]; beq=[];
lb = WIvector; ub=Inf*ones(size(WIvector));
Wvector = fmincon(fun,WIvector,A,b,Aeq,beq,lb,ub);

end
