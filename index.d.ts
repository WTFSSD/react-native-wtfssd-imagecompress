

declare class ImageCompress{
    /**
     * 压缩图片
     * @param {string} url
     * @param {number} size
     * @return {Promise<any>}
     */
    static compress  (url:string,size:number):Promise<any>
}