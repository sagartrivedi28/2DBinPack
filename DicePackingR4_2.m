function [Fcor,Fsets,Fwafer] = DicePackingR4_2( Did,Ddimx,Ddimy,Dvol,Dreq,Gpara,ax,wsize)

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
Wcnt = Inf;
NIso1mm = Iso1mm(ind1);

th_NDdimy=1.25;                                    %empty not enough ==> allow shorter y-size dice placement  
th_nRow=1.2;                                          %as previously placed dice's ysize > th_nRow*new_ysize ==> trigger multi-row mode 
[~,ind_mvol]=sort(NDvol,'ascend');          %sort by volume
[~,~,vol_grp]=unique(NDvol(ind_mvol));
ind_vol=zeros(size(ind_mvol));
for i=1:max(vol_grp)                                 %same volume sort by ydim 
    ind_vol(vol_grp==i)=sort(ind_mvol(vol_grp==i),'descend');
end

for W = Rmax(1):-1000:12000 %max(NDdimx)
    
    i=1;
    T_height=0;
	shelf.height = [];
	shelf.empty = W;
	shelf.Dinfo = [];
    shelf.level=[];
    shelf.nRow=1; % for multiple row optimization
    height_nRow=0;
	Dcor = zeros(N,4);
    DPool=true(N,1);
    newnRow=false;
    
   while any(DPool)

         n=find(DPool,1,'first');
         if ~any(shelf(i).empty(1) >= NDdimx(n) & DPool(n))
               n=find(shelf(i).empty(1) >= NDdimx & DPool & NDdimy>=height_nRow(1)/th_NDdimy,1,'first');
         end
         n_multi=[];
                
         if ~isempty(n)
             if shelf(i).empty==W% Single Rows Initialization
             shelf(i).height = NDdimy(n);
             shelf(i).level = T_height;
             shelf(i).nRow = 1;
             height_nRow=shelf(i).height;
             height_empty=0;
             T_height = T_height+NDdimy(n);
             else
               nRow=shelf(i).height/NDdimy(n);
               if length(shelf(i).empty)==1 && nRow>=th_nRow % Multiple Rows Initialization
               shelf(i).nRow=ceil(nRow);
               shelf(i).empty=shelf(i).empty*ones(ceil(nRow),1);
               newnRow=true;
               end
             end
             
             DPool(n)=false;
             [shelf,Dcor,Dloc(1)] = BulidShelf(shelf,Dcor,W,NDid,NDdimx,NDdimy,i,n,height_nRow,1); %Single Row
             if newnRow;height_nRow(1)=NDdimy(n);end;
         end
         
         for nr=2:shelf(i).nRow % Multi-Row
              if newnRow
                 height_empty(nr)=shelf(i).height-sum(height_nRow);
              else
                 height_empty(nr)=height_nRow(nr)+(shelf(i).height-sum(height_nRow))*(nr==shelf(i).nRow);
              end
              x_empty=shelf(i).empty(nr)>=NDdimx(ind_vol);
              y_empty=height_empty(nr)>=NDdimy(ind_vol);
              n_multi = ind_vol(find(x_empty & y_empty & DPool(ind_vol),1,'first'));
              if ~isempty(n_multi)
                   if newnRow;height_nRow(nr)=NDdimy(n_multi);end;
                      DPool(n_multi) = false;
                      [shelf,Dcor,Dloc(nr)] = BulidShelf(shelf,Dcor,W,NDid,NDdimx,NDdimy,i,n_multi,height_nRow,nr);
              end
         end
              shelf(i).nRow=length(height_nRow);
              newnRow=false;

%               if NIso1mm(n)~=0
%                  Dcor(NDid(n),:) = [Dloc+IValue/2,shelf(i).level+IValue/2,Dloc+NDdimx(n)-IValue,shelf(i).level+NDdimy(n)-IValue];
%                     if (shelf(i).empty+NDdimx(n))~=W && Iso1mm(shelf(i).Dinfo(end-1,1))~=0
%                         shelf(i).empty = shelf(i).empty+IValue;
%                         Dcor(NDid(n),:) = [Dloc+IValue/2-IValue,shelf(i).level+IValue/2,Dloc+NDdimx(n)-2*IValue,shelf(i).level+NDdimy(n)-IValue];
%                         temp = shelf(i).Dinfo(end-1,:);
%                         shelf(i).Dinfo(end-1,:) = [temp(1) temp(2)-IValue/2 temp(3) temp(4)];
%                         shelf(i).Dinfo(end,:) = [temp(1) temp(2)-IValue/2 temp(3)-IValue/2 temp(4)];
%                     end;
%               end;

              if isempty(n) && isempty(n_multi)
                 [Dcor,shelf]=xEqualSpace(Dcor,shelf,W,i);
                 i=i+1;
                 shelf(i).empty=W;
                 height_nRow=0;
              end

    end;
    [Dcor,shelf] = xEqualSpace(Dcor,shelf,W,i); 
     Dcor = EdgeAlignment(Dcor,shelf,W,Dvol);    
    
%     for sh=1:length(shelf(1).Dinfo(:,1))
%         if (shelf(1).Dinfo(sh,end) > shelf(end).height) && ((W-shelf(1).Dinfo(sh,3)) > (W-shelf(end).empty))
%             
%             shelf(end).Dinfo(:,3) = shelf(end).Dinfo(:,3) + shelf(1).Dinfo(sh,3);
%             shelf(end).Dinfo(:,4) = shelf(end).Dinfo(:,4) + (shelf(1).Dinfo(sh,end)-shelf(end).height);
%             shelf(end).level = shelf(1).height-shelf(1).Dinfo(sh,end);
%             
%             for s1 = 1:length(shelf(end).Dinfo(:,1))
%                 D1 = shelf(end).Dinfo(s1,1);                
%                 Dcor(D1,:) = [shelf(end).Dinfo(s1,3), shelf(end).level,...
%                     shelf(end).Dinfo(s1,3) + shelf(end).Dinfo(s1,2),...
%                     shelf(end).level+(shelf(end).height-shelf(end).Dinfo(s1,4))];                
%             end;
%             
%             break;            
%         end;
%         
%     end

if ~isempty(wsize)
    Rnew = [max(Dcor(:,3))-min(Dcor(:,1)) max(Dcor(:,4))-min(Dcor(:,2))]/10^3;  
    [map_in,~,~,~,~,~] = DieOffset(Rnew(1),Rnew(2),wsize,[]);
    GDPW = sum(map_in(:));
else
    GDPW = 1;
end    

    % Need to re-arrange Shelves to get maxima yield
    
    if T_height< Rmax(2)
        Cmat = Cgraph(Dcor,Dvol,N);
        [sets, Wvector] = CGpartition(Cmat,Dvol,N,Rno);
        if Wcnt>sum(ceil(Wvector/GDPW))
            Wcnt = sum(ceil(Wvector/GDPW));            
            Fwafer = Wvector;
            Fshelf = shelf;
            Fcor = Dcor;
            FCmat = Cmat;
            Fsets = sets;
        end;
    end;
    shelf=[];

end;

% figure; imshow(FCmat,[]); colormap jet;
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
% Vunit = min(Tvol(Tvol~=0));

sets=false(size(Cmat(:,1)));
% Tvol(temp(1))=0;

while sum(Tvol)
    temp = find(Tvol==min(Tvol(Tvol~=0)));
    Sflag = false;
    
    for l=1:size(sets,2) 
            if ~((sum(Cmat(:,temp(1)).*sets(:,l)) || sets(temp(1),l)) || Sflag)
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

fun = @(Wvector) sum(Bsets*ceil(Wvector)-NDvol); %fun = @(Wvector) sum(ceil(Wvector));
A=-Bsets;
b=-NDvol;
Aeq=[]; beq=[];
lb = WIvector; ub=Inf*ones(size(WIvector));
Wvector = fmincon(fun,WIvector,A,b,Aeq,beq,lb,ub);

end

function [shelf,Dcor,Dloc] = BulidShelf(shelf,Dcor,W,NDid,NDdimx,NDdimy,i,n,H_nRow,nr)

      H_nRow_Room=H_nRow(nr)-NDdimy(n)+(shelf(i).height-sum(H_nRow))*(nr==shelf(i).nRow);
      if nr>length(shelf(i).level)
           shelf(i).level(nr)=shelf(i).level(1)+H_nRow(nr-1);
      end
      Dloc = W-shelf(i).empty(nr);
      shelf(i).empty(nr) = shelf(i).empty(nr)-NDdimx(n);
      shelf(i).Dinfo = [shelf(i).Dinfo; NDid(n) NDdimx(n) Dloc H_nRow_Room];  % ID, X-dimention, X-location, Height Leftover
      Dcor(NDid(n),:) = [Dloc,shelf(i).level(nr),Dloc+NDdimx(n),shelf(i).level(nr)+NDdimy(n)];

end

function [Dcor,shelf]=xEqualSpace(Dcor,shelf,W,i)
                
                Dcor_i = Dcor(shelf(i).Dinfo(:,1),:);
               [~,~,level_grp]=unique(Dcor_i(:,2)); % find the xo of multi-row
                InterSect_bw=sum(Dcor_i(:,3)*ones(1,length(Dcor_i(:,1)))==ones(length(Dcor_i(:,3)),1)*(Dcor_i(:,1).'),2)==2;
                W_shelf=W-min(shelf(i).empty);
                xo_nRow_shelf=Dcor_i(InterSect_bw,3); if isempty(xo_nRow_shelf);xo_nRow_shelf=0;end;
                
                PREnRow=Dcor_i(:,3)<=xo_nRow_shelf;
                level_grp(~PREnRow)=level_grp(~PREnRow)+1*any(PREnRow);

                empty=shelf(i).empty;
                xoffset=zeros(size(empty));
                
                if any(PREnRow) % shift in x from the xo of multi-row
                     xoffset=min(shelf(i).empty)*xo_nRow_shelf/W_shelf; 
                     shelf(i).empty=shelf(i).empty-xoffset;                          
                     empty=[xoffset;shelf(i).empty-xoffset];                       
                     xoffset=[0;xoffset*ones(length(empty)-1,1)];
                end
                
                for s=1:max(level_grp) %equally distribute the empty space in x for shelf i 
                    
                     sublevel=level_grp==s;
  
                     Dcor_subset=Dcor(shelf(i).Dinfo(sublevel,1),:);
                     shelf_Dinfo_subset = shelf(i).Dinfo(sublevel,3);
                     delta=empty(s)/(sum(sublevel))+eps;  
                     [~,ind]=sort(Dcor_subset(:,1));
                     Dcor_subset(ind,[1,3])=Dcor_subset(ind,[1,3])+((0:delta:(sum(sublevel)-1)*delta).')*ones(1,2)+xoffset(s);
                     shelf_Dinfo_subset(ind)=shelf_Dinfo_subset(ind)+xoffset(s);
                     
                     Dcor(shelf(i).Dinfo(sublevel,1),:)=Dcor_subset;
                     shelf(i).Dinfo(sublevel,3)=shelf_Dinfo_subset;
                     
                end

end

function Dcor = EdgeAlignment(Dcor,shelf,W,Dvol)
    
    xshift=Dvol==0;
    for i=1:length(shelf)
          level(i) = shelf(i).level(1);
    end
    level(end+1)=inf;
    
    while any(~xshift)
       n=find(~xshift,1,'first'); xshift(n)=true;
       ind=find(Dcor(n,2)>=level,1,'last');
       SameShelf = level(ind) <= Dcor(:,2) & Dcor(:,2) < level(ind+1);
       Dcor_shelf=Dcor(SameShelf,:);
       v_min = [0;Dcor_shelf(:,3)]-Dcor(n,1);
       v_min = max(v_min(v_min<=0));
       v_max = [Dcor_shelf(:,1);W]-Dcor(n,3);
       v_max = min(v_max(v_max>=0));
       
       Cmat = Cgraph(Dcor,Dvol,size(Dcor,1));
       C0mat=Cmat(:,n) & ~SameShelf & Dvol~=0;
       C0 = sum(C0mat.*Dvol);
       
       v = [Dcor(~SameShelf,1)-Dcor(n,1);...
              Dcor(~SameShelf,3)-Dcor(n,1);...
              Dcor(~SameShelf,1)-Dcor(n,3);...
              Dcor(~SameShelf,3)-Dcor(n,3)];
       v = v(v_min<=v & v<=v_max);
       Dcor0=Dcor;
       for i=1:length(v)
           Dcor_tmp = Dcor;
           Dcor_tmp(n,[1,3])=Dcor_tmp(n,[1,3])+v(i);
           Cmat = Cgraph(Dcor_tmp,Dvol,size(Dcor,1));
           Cmat = Cmat(:,n) & ~SameShelf & Dvol~=0;
           C = sum(Cmat.*Dvol);
           if ~any(~C0mat & Cmat) && C0>C %New Conflict Are Not Allowed
                Dcor0=Dcor_tmp;
                C0=C;
                C0mat=Cmat;
           end
       end
       Dcor=Dcor0;
    end
end
