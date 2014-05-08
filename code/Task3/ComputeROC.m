function ComputeROC(Cparams, Fdata, NFdata)
%COMPUTEROC

if (~exist('data/testimscores.mat', 'file'))
    facelist = ListDirImages(Fdata.dirname);
    nonfacelist = ListDirImages(NFdata.dirname);
    
    facetraining = Fdata.fnums;
    nftraining = NFdata.fnums;
    
    % facetest = setdiff(3:numel(facelist), facetraining);
    % nftest = setdiff(3:numel(nonfacelist), nftraining);
    
    facetest = setdiff(1:numel(facelist), facetraining);
    nftest = setdiff(1:numel(nonfacelist), nftraining);
    
    ftestnames = facelist(facetest);
    nftestnames = nonfacelist(nftest);
    
    score = zeros(numel(nftestnames) + numel(ftestnames), 1);
    labels = [ones(numel(ftestnames), 1); zeros(numel(nftestnames), 1)];
    
    lastind = 0;
    for i=1:numel(ftestnames)
        [~, ii_im] = LoadIm(ftestnames{i});
        score(i) = ApplyDetector(Cparams, ii_im);
        lastind = i;
    end
    
    for i=1:numel(nftestnames);
        [~, ii_im] = LoadIm(nftestnames{i});
        score(lastind + i) = ApplyDetector(Cparams, ii_im);
    end
    
    save('data/testimscores.mat', 'score', 'labels')
end

thresholds = 0:0.05:10;
tpr = zeros(numel(thresholds),1);
fpr = zeros(numel(thresholds),1);
for i=1:numel(thresholds)
    load('data/testimscores.mat')
    classification = score > thresholds(i);
    truepos = sum((classification == 1) & (labels == 1));
    trueneg = sum((classification == 0) & (labels == 0));
    falsepos = sum((classification == 1) & (labels == 0));
    falseneg = sum((classification == 0) & (labels == 1));

    tpr(i) = truepos/(truepos + falseneg);
    fpr(i) = falsepos/(trueneg + falsepos);
end

figure
plot(fpr, tpr)
xlabel('fpr')
ylabel('tpr')
    
end