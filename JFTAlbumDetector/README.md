# AlbumDetector
find out some photo in album without face inside

to improve accuracy, change faceDetectImageSize to a larger size.

    - static CGSize const faceDetectImageSize = {200, 200};

    + static CGSize const faceDetectImageSize = {400, 400};

Because this is a test demo, some feature may not implemented or not tested yet.

So someting may went wrong if:
- Album have changed.
- JFTPHAssetFaceDetecteOperation.networkNeed == true.
