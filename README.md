# react-native-wtfssd-imagecompress

# install 
- `npm install react-native-wtfssd-imagecompress --save`
# link
- `react-native link  react-native-wtfssd-imagecompress`

# usage

```
import ImageCompress from 'react-native-wtfssd-imagecompress';

ImageCompress.compress(imageurl,size).then(response => {
    console.log('success',response);
}).catch(e => {
    console.log('error', e);
});

```

### paramlist
- `imageUrl` the url of image
- `size` expect size of compress (unit:kb)

### response contained the follow fields
 - `data` the `base64` string
 - `fileName` the name of image(unit:B)
 - `size` the compressed size of image 
 - `origin` the origin url of image                                       
 - `originSize` the size of origin image (unit:B)