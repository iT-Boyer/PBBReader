https://www.raywenderlich.com/17811/how-to-make-a-simple-mac-app-on-os-x-10-7-tutorial-part-13

#####UTI:(Uniform Type Identifier Concepts)
Uniform type identifiers (UTIs) provide a unified way to identify data handled within the system, such as documents, pasteboard data, and bundles.

Because UTIs can identify any class of entity, they are much more flexible than the older tagging methods; you can also use them to identify any of the following entities:

Pasteboard data
Folders (directories)
Bundles
Frameworks
Streaming data
Aliases and symbolic links
In addition, `you can define your own UTIs for application-specific use.` For example, if your application uses a special document format, you can declare a UTI for it. Third-party applications or plug-ins that want to support your format can then use that UTI to identify your files.

#####Declaring UTIs

An imported UTI declaration is used to declare a type that the bundle does not own, but would like to see available on the system. For example, say a video-editing program creates files using a proprietary format whose UTI is declared in its application bundle. If you are writing an application or plugin that can read such files, you must make sure that the system knows about the proprietary UTI, even if the actual video-editing application is not available. To do so, your application should redeclare the UTI in its own bundle but mark it as an imported declaration.


#####实现双击启动APP功能 
[UTI iPhone支持依文件后缀名打开应用](http://blog.csdn.net/zaitianaoxiang/article/details/6658492)
[OSX下自定义文件类型和QuickLook](http://ixhan.com/2012/02/define-custom-file-format-on-osx/)
第一步：先配置UTI，使系统上的其他应用程序能知道它的存在。
1. UTTypeIdentifier:com.cn.pyc.pbbReader
2. UTTypeConformsTo: public.data // 设置之后，打开方式列表中只显示本应用。
此时右击后缀.pbb文件，就会出现系统上其他应用程序的列表。
第二步：配置Document Type ：
1. CFBundleTypeIconFiles：两个图像将作为支持的邮件和其他应用程序能够显示文件类型的图标。
2. LSItemContentTypes：键可让您提供一个可以使您的应用程序打开的统一类型标识符（UTI）数组.此处就是关联第一步的UTTypeIdentifier的。




