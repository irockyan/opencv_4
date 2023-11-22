package ar.fgsoruco.opencv4.factory.imagefilter

import org.opencv.core.Mat
import org.opencv.core.MatOfByte
import org.opencv.core.Size
import org.opencv.imgcodecs.Imgcodecs
import org.opencv.imgproc.Imgproc
import java.io.FileInputStream
import java.io.InputStream
import io.flutter.plugin.common.MethodChannel
import org.opencv.core.Core
import org.opencv.core.Scalar
import android.util.Log
class MergeAlphaFactory {
    companion object{

        fun process(pathType: Int,pathString: String, data: ByteArray, alphaPercent: Double, result: MethodChannel.Result) {
            when (pathType){
                1 -> result.success(mergeAlphaS(pathString, alphaPercent))
                2 -> result.success(mergeAlphaB(data, alphaPercent))
                3 -> result.success(mergeAlphaB(data, alphaPercent))
            }
        }

        //Module: Image Filtering
        private fun mergeAlphaS(pathString: String, alphaPercent: Double): ByteArray? {
            val inputStream: InputStream = FileInputStream(pathString.replace("file://", ""))
            val data: ByteArray = inputStream.readBytes()

            try {
                var byteArray = ByteArray(0)
                var dst = Mat()
                // Decode image from input byte array
                val filename = pathString.replace("file://", "")
                val src = Imgcodecs.imread(filename)

                if (src.channels() == 4 && alphaPercent != 1.0) {
                    val img_rgba = ArrayList<Mat>(4)
                    Core.split(src, img_rgba)
                    // 改变 alpha 通道的值
                    Core.multiply(img_rgba[3], Scalar(alphaPercent), img_rgba[3])
                    Core.merge(img_rgba, dst)
                } else {
                    dst = src.clone()
                }

                // instantiating an empty MatOfByte class
                val matOfByte = MatOfByte()
                // Converting the Mat object to MatOfByte
                Imgcodecs.imencode(".png", dst, matOfByte)
                byteArray = matOfByte.toArray()
                return byteArray
            } catch (e: java.lang.Exception) {
                println("OpenCV Error: $e")
                return data
            }

        }

        //Module: Image Filtering
        private fun mergeAlphaB(data: ByteArray, alphaPercent: Double): ByteArray? {

            try {
                var byteArray = ByteArray(0)
                var dst = Mat()
                // Decode image from input byte array
                Log.i("OpenCV", "Decoding Image $alphaPercent")
                val src = Imgcodecs.imdecode(MatOfByte(*data), Imgcodecs.IMREAD_UNCHANGED)
                if(alphaPercent == 1.0){
                    return data
                }
                if (src.channels() != 4) {
                    Imgproc.cvtColor(src, src, Imgproc.COLOR_BGR2BGRA)
                }
                val img_rgba = ArrayList<Mat>(4)
                Core.split(src, img_rgba)
                // 改变 alpha 通道的值
                Core.multiply(img_rgba[3], Scalar(alphaPercent), img_rgba[3])
                Core.merge(img_rgba, dst)
                Log.i("OpenCV", "Decoding Image 1 ${dst.channels()} ${img_rgba[3]}")
                val pixel = dst.get(0, 0)
                Log.i("OpenCV", "Pixel at ($0, $0): ${pixel.contentToString()}")
                // instantiating an empty MatOfByte class
                val matOfByte = MatOfByte()
                // Converting the Mat object to MatOfByte
                Imgcodecs.imencode(".png", dst, matOfByte)
                byteArray = matOfByte.toArray()
                return byteArray
            } catch (e: java.lang.Exception) {
                println("OpenCV Error: $e")
                return data
            }

        }

    }
}