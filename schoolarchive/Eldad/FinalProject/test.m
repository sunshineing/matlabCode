% delta = linspace(0.001,0.01,20);
% 
% 
% for ii = 1:length(delta)
%     phid_delta = (Q * Um(mit,q,A1,A2,A3) - d) ./ (abs(dev)); %+ delta(ii));
%     phiD_delta(ii) = phid_delta' * phid_delta;
% 
% end
% figure(23)
% subplot(2,1,1)
%     plot(delta,phiD_delta)
%     title('Water Level stabalizer for data Misfit calculation')
%     xlabel('Chosen Delta')
%     ylabel('| (Qu - d)/sigma | ^2')
% 



for jj = 1:length(alpha)
    
    mInv = reshape(Mit(:,jj),n1,n2,n3);
    
    figure(242)
    for ii = 1:9
        subP = subplot(3,3,ii);
        %contourf(mInv(:,:,ii))
        imagesc(mInv(:,:,ii))
        title(sprintf('Depth z = %d, Alpha = %e',(ii-1)*10,alpha(jj)))
        caxis([min(min(min(mInv))) max(max(max(mInv)))])
        pos=get(subP, 'Position');
        set(subP, 'Position', [pos(1)+0.05 pos(2) pos(3) pos(4)])
        %caxis(cax)  %Turn on for absolute color cross over between fig 1
        %and fig 2
    end
    B=colorbar ('FontSize',12);
    set(B, 'Position', [.0314 .11 .0581 .8150])
    ylabel(B,'Conductivity anomaly [dimensionless]')
    pause(2)
   
end