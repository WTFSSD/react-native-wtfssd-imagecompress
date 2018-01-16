const {NativeModules} = require('react-native');

const imagecompress = NativeModules.ImageCompress;
export default  class ImageCompress{
    /**
     *
     * @param {number} url
     * @param {string} size
     * @retun Promise<any>
     */
    static compress = (url,size)=>{
        // console.log('压缩图片',url,'到',`size:${size}kb`);
       return  imagecompress.compress(url,size);
    }
}
