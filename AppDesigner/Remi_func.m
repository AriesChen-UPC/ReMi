function [ RF_STACK,f,p ] = Remi_func( n,dn,seis,nw,np,npad,percent,samplerate,loop,n_cut,n_select,pmax,pmax1,pmin,pmin1)
% REMI_FUNC ����Remi������ȡƵɢ����

%   [ RF_STACK,f,p ] = Remi_func( n,dn,seis,nw,np,npad,percent,samplerate,loop,n_cut,pmax,pmax1,pmin,pmin1 )
%   [ RF_STACK,f,p ] = Remi_func( n,dn,seis,nw,np,npad,percent,samplerate,loop,n_cut)
%   [ RF_STACK,f,p ] = Remi_func( n,dn,seis,nw,samplerate)

%  ******** �������˵��*********
% n= �첨����Ŀ
% dn= �첨����ࣨm��
% seis= ԭʼ���ݾ���
% nw= ���ݿ�����Ŀ
% np= ������������
% npad= FFT�������
% percent= FFT�������Ȱٷֱ�
% samplerate= ԭʼ���ݲ�����
% loop= �Ƿ�ѭ������ 1�����ǣ�0�����default=0
% n_cut= ����ѭ������Ľڵ���Ŀ

% pmax= �������������ֵ  default=1e-2;
% pmin= ������������Сֵ  default=1e-3;
% pmax1= �������������ֵ default=-1e-3;
% pmin1= ������������Сֵ default=-1e-2;

% ***********�������˵��*************
% RF_STACK=ȫ�����ڵ��Ӻ�����ױ�ֵ����
% f=Ƶ������
% p=��������

% By Y Zheng, June 2021

%%

if nargin<14
    pmax = 1e-2;  
    pmin = 0;  % ������������Сֵ/���ֵ
    pmax1 = 0;  
    pmin1 = -1e-2;  % ������������Сֵ/���ֵ
end

if nargin < 10
    np = 100;
    npad = 1000;
    percent = 10;
    loop = 0;  % �������������� FFT���������FFT�����ص��ٷֱ�; �Ƿ�ѭ������
end

if loop ~= 0        % �ж��Ƿ����ѭ������
    x = 0:dn:(n_cut-1)*dn;    % Ҫ����ѭ�����㣬�ڵ�λ��ʸ����ѡȡ�Ľڵ���Ŀ����
else
    x = 0:dn:(n_select-1)*dn;        % ������ѭ�����㣬�ڵ�λ��ʸ����ȫ�ڵ����
end

dp = (pmax-pmin)/np;  %������������������ò���ֱ��Ӱ�����׾���ĵڶ���ά��
t_window = round(length(seis)/samplerate)/nw;  %����ÿ������ʱ�䳤��
RF_STACK = zeros(round(npad/2)+1,round((pmax-pmin)/dp+1));  % Ԥ������Ӻ����
h1 = waitbar(0,'please wait');  % ���ý�����

for j = 1:nw  % ���ڵ��Ӽ���
    delta_data = floor((length(seis-1))/nw);  % ����ÿ���������ݳ��ȣ�20��ʾ��20����
    seis_windows = seis((j-1)*delta_data+1:j*delta_data,:);
    t = linspace(0,t_window,length(seis_windows));  % ��������ʱ��ʸ��
    t = t';
    %
    [stp,tau,p] = tptran(seis_windows,t,x,pmin1,pmax1,dp);  % ����Crews tau-p �任���������㸺����Tau-p tran
    [spec,f] = fftrl(stp,tau,percent,npad);  % ����Crews fft
    PF2 = (spec.*conj(spec));  % ����Ԫȡģ��
    [stp,tau,p] = tptran(seis_windows,t,x,pmin,pmax,dp);  % ����Crews tau-p �任����,����������Tau-p tran
    [spec,f] = fftrl(stp,tau,percent,npad);  % ����Crews fft
    PF1 = (spec.*conj(spec));
    PF = PF1+fliplr(PF2);  % ���������������׵���
    RF = PF;
    Sf = (1/length(p))*sum(PF,2);  % ���׾����һ��ϵ������

    for i = 1:length(Sf)
        RF(i,:) = RF(i,:)/Sf(i,1);  % �������׹�һ��ϵ������ ���ױ�
    end
    RF_STACK = RF_STACK+RF;  % �������д��ڵ��Ӻ�����ױ�
    str = ['Progress...',num2str(round(j/(nw)*100)),'%'];  % ���ȼ���
    waitbar(j/(nw),h1,str)
end
delete(h1);
end

