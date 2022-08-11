close all; clear,clc
Data_compressed = DIC_tracing_semi_automatic('Compressed',15,5);
Data_uncompressed = DIC_tracing_semi_automatic('Uncompressed',8,1);

ratio_c = (Data_compressed(:,4)./Data_compressed(:,3))./((Data_compressed(:,6)-Data_compressed(:,4))./(Data_compressed(:,5)-Data_compressed(:,3)));
ratio_u = (Data_uncompressed(:,4)./Data_uncompressed(:,3))./((Data_uncompressed(:,6)-Data_uncompressed(:,4))./(Data_uncompressed(:,5)-Data_uncompressed(:,3))); 