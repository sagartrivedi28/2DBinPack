function [Fcor,Fsets] = DicePacking( Did,Ddimx,Ddimy,Dvol,Dreq,Gpara,ax)

%%%%%%%%%%%%% Tasks Left %%%%%%%%%%%%%%%%%%%%%
%{
1. As Per Dice Volume Optimize the reticle area & Dice count
2. Arrange shelves betterway: need to align same width/height dices
3. Conflict Graph Generation Algorithm: Need to consider 300nm adjacent cut
4. Graph Partition Algorithm: Need to consider the SameCut Dice
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Rmax = Gpara.Rmax;
Sline = Gpara.Sline;

[NDdimy,ind1] = sort(Ddimy,'descend');
NDid = Did(ind1);
NDdimx = Ddimx(ind1);
NDvol = Dvol(ind1);
N = length(NDid);
Maxset = N;

for W = Rmax(1):-10^3:max(NDdimx)
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
                shelf(i).empty=shelf(i).empty-NDdimx(n);
                shelf(i).Dinfo = [shelf(i).Dinfo; NDid(n) NDdimx(n) Dloc (shelf(i).height-NDdimy(n))];  % ID, X-dimention, X-location, Height Leftover
                Dcor(NDid(n),:) = [Dloc,shelf(i).level,Dloc+NDdimx(n),shelf(i).level+NDdimy(n)];
                Dflag = false;
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
   
    % Need to re-arrange Shelves to get maxima yield
    
    if T_height< Rmax(2)
        Cmat = Cgraph(Dcor,N);
        sets = CGpartition(Cmat,N);
        if Maxset>length(sets)
            Maxset=length(sets);
            Fshelf = shelf;
            Fcor = Dcor;
            FCmat = Cmat;
            Fsets = sets;            
        end;
    end;
    shelf=[];

end;

Rshift = [max(Fcor(:,3))-min(Fcor(:,1)) max(Fcor(:,4))-min(Fcor(:,2))]/2;
axes(ax);
cla;
axis(1.1*[-Rmax(1)/2,Rmax(1)/2+1,-Rmax(2)/2-1,Rmax(2)/2+1]);
rectangle('Position',[-Rmax(1)/2,-Rmax(2)/2,Rmax(1),Rmax(2)],'LineWidth',2,'LineStyle','--','EdgeColor','r');
rectangle('Position',[-Rshift(1),-Rshift(2),2*Rshift(1),2*Rshift(2)],'LineWidth',2,'LineStyle','--');
SetsColor = jet(length(Fsets));
for l=1:length(Fsets)        
    for i=1:length(Fsets{l})
        rectangle('Position',[Fcor(Fsets{l}(i),1)+(Sline/2)-Rshift(1), Fcor(Fsets{l}(i),2)+(Sline/2)-Rshift(2),Ddimx(Fsets{l}(i))-Sline,Ddimy(Fsets{l}(i))-Sline],'LineWidth',1,'FaceColor','c');
        rectangle('Position',[Fcor(Fsets{l}(i),1)-Rshift(1),Fcor(Fsets{l}(i),2)-Rshift(2),Ddimx(Fsets{l}(i)),Ddimy(Fsets{l}(i))],'LineWidth',1,'LineStyle','--','EdgeColor','b');
        text(Fcor(Fsets{l}(i),1)-Rshift(1)+Ddimx(Fsets{l}(i))/2,Fcor(Fsets{l}(i),2)-Rshift(2)+Ddimy(Fsets{l}(i))/2,num2str(Fsets{l}(i)),'FontSize',8,'BackgroundColor',SetsColor(l,:));
    end;
end;
text(0,Rshift(2)+1000,['Detected Minima Cut-Sets: ' num2str(length(Fsets))],'FontSize',12);
end

% Conflict Graph Generation Algorithm: Need to consider 300nm adjacent cut
function Cmat = Cgraph(Dcor,N)
Cmat = false(N);
for k1=1:N
    for k2=1:N
        if ((Dcor(k1,1) < Dcor(k2,1)) && (Dcor(k2,1) < Dcor(k1,3))) || ((Dcor(k1,1) < Dcor(k2,3)) && (Dcor(k2,3) < Dcor(k1,3))) || ...
                ((Dcor(k1,2) < Dcor(k2,2)) && (Dcor(k2,2) < Dcor(k1,4))) || ((Dcor(k1,2) < Dcor(k2,4)) && (Dcor(k2,4) < Dcor(k1,4)))                
            Cmat(k1,k2)=1;
        end;
    end;
end;
Cmat = Cmat | Cmat';
end

% Graph Partition Algorithm: Need to consider the SameCut Dice
function sets = CGpartition(Cmat,N)
sets{1}=1;
for k=2:N
    Sflag = false(length(sets),1);
    Slength = zeros(length(sets),1);
    for l=1:length(sets)
        Slength(l)=length(sets{l});
        for i=1:length(sets{l})
            if Cmat(sets{l}(i),k)
                Sflag(l)=1;
            end;
        end;
    end;
    Slength = Slength.*(~Sflag);
    if sum(Slength)
        setID = find(Slength==max(Slength));
        sets{setID(1)} = [sets{setID(1)} k];
    else
        sets = [sets k];
    end;
    
end;

end
