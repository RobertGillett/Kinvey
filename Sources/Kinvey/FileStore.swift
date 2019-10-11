//
//  FileStore.swift
//  Kinvey
//
//  Created by Victor Barros on 2016-02-04.
//  Copyright © 2016 Kinvey. All rights reserved.
//

import Foundation
import PromiseKit

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

/// Enumeration to describe which format an image should be represented
public enum ImageRepresentation {
    
    /// PNG Format
    case png
    
    /// JPEG Format with a compression quality value
    case jpeg(compressionQuality: Float)

#if os(macOS)
    
    func data(image: NSImage) -> Data? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        let newRep = NSBitmapImageRep(cgImage: cgImage)
        newRep.size = image.size
        var fileType: NSBitmapImageRep.FileType!
        var properties: [NSBitmapImageRep.PropertyKey : Any]!
        switch self {
        case .png:
            fileType = .png
            properties = [:]
        case .jpeg(let compressionQuality):
            fileType = .jpeg
            properties = [.compressionFactor : compressionQuality]
        }
        return newRep.representation(using: fileType, properties: properties)
    }
    
#else

    func data(image: UIImage) -> Data? {
        switch self {
        case .png:
            return image.pngData()
        case .jpeg(let compressionQuality):
            return image.jpegData(compressionQuality: CGFloat(compressionQuality))
        }
    }
    
#endif
    
    var mimeType: String {
        switch self {
        case .png: return "image/png"
        case .jpeg: return "image/jpeg"
        }
    }
    
}

/// Class to interact with the `Files` collection in the backend.
open class FileStore<FileType: File> {
    
    @available(*, deprecated, message: "Deprecated in version 3.17.0. Please use Result<FileType, Swift.Error> instead")
    public typealias FileCompletionHandler = (FileType?, Swift.Error?) -> Void
    
    @available(*, deprecated, message: "Deprecated in version 3.17.0. Please use Result<(FileType, Data), Swift.Error> instead")
    public typealias FileDataCompletionHandler = (FileType?, Data?, Swift.Error?) -> Void
    
    @available(*, deprecated, message: "Deprecated in version 3.17.0. Please use Result<(FileType, URL), Swift.Error> instead")
    public typealias FilePathCompletionHandler = (FileType?, URL?, Swift.Error?) -> Void
    
    @available(*, deprecated, message: "Deprecated in version 3.17.0. Please use Result<UInt, Swift.Error> instead")
    public typealias UIntCompletionHandler = (UInt?, Swift.Error?) -> Void
    
    @available(*, deprecated, message: "Deprecated in version 3.17.0. Please use Result<[FileType], Swift.Error> instead")
    public typealias FileArrayCompletionHandler = ([FileType]?, Swift.Error?) -> Void
    
    internal let client: Client
    internal let cache: AnyFileCache<FileType>?
    
    /**
     Constructor that takes a specific `Client` instance or use the
     `sharedClient` instance
     */
    public init(client: Client = sharedClient) {
        self.client = client
        self.cache = client.cacheManager.fileCache(fileURL: client.fileURL())
    }

#if os(macOS)
    
    /// Uploads a `UIImage` in a PNG or JPEG format.
    @available(*, deprecated, message: "Deprecated in version 3.17.0. Please use FileStore.upload(_:image:imageRepresentation:options:completionHandler:) instead")
    @discardableResult
    open func upload(
        _ file: FileType,
        image: NSImage,
        imageRepresentation: ImageRepresentation = .png,
        ttl: TTL? = nil,
        completionHandler: FileCompletionHandler? = nil
    ) -> AnyRequest<Swift.Result<FileType, Swift.Error>> {
        return upload(
            file,
            image: image,
            imageRepresentation: imageRepresentation,
            ttl: ttl
        ) { (result: Swift.Result<FileType, Swift.Error>) in
            result.into(completionHandler: completionHandler)
        }
    }
    
    /// Uploads a `UIImage` in a PNG or JPEG format.
    @discardableResult
    @available(*, deprecated, message: "Deprecated in version 3.18.0. Please use FileStore.upload(_:image:imageRepresentation:options:completionHandler:) instead")
    open func upload(
        _ file: FileType,
        image: NSImage,
        imageRepresentation: ImageRepresentation = .png,
        ttl: TTL? = nil,
        completionHandler: ((Swift.Result<FileType, Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<FileType, Swift.Error>> {
        return upload(
            file,
            image: image,
            imageRepresentation: imageRepresentation,
            options: try! Options(ttl: ttl),
            completionHandler: completionHandler
        )
    }
    
    /// Uploads a `UIImage` in a PNG or JPEG format.
    @discardableResult
    open func upload(
        _ file: FileType,
        image: NSImage,
        imageRepresentation: ImageRepresentation = .png,
        options: Options? = nil,
        completionHandler: ((Swift.Result<FileType, Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<FileType, Swift.Error>> {
        let data = imageRepresentation.data(image: image)!
        file.mimeType = imageRepresentation.mimeType
        return upload(
            file,
            data: data,
            options: options,
            completionHandler: completionHandler
        )
    }
    
#else

    /// Uploads a `UIImage` in a PNG or JPEG format.
    @discardableResult
    @available(*, deprecated, message: "Deprecated in version 3.17.0. Please use FileStore.upload(_:image:imageRepresentation:options:completionHandler:) instead")
    open func upload(
        _ file: FileType,
        image: UIImage,
        imageRepresentation: ImageRepresentation = .png,
        ttl: TTL? = nil,
        completionHandler: FileCompletionHandler? = nil
    ) -> AnyRequest<Swift.Result<FileType, Swift.Error>> {
        return upload(
            file,
            image: image,
            imageRepresentation: imageRepresentation,
            ttl: ttl
        ) { (result: Swift.Result<FileType, Swift.Error>) in
            result.into(completionHandler: completionHandler)
        }
    }
    
    /// Uploads a `UIImage` in a PNG or JPEG format.
    @discardableResult
    @available(*, deprecated, message: "Deprecated in version 3.17.0. Please use FileStore.upload(_:image:imageRepresentation:options:completionHandler:) instead")
    open func upload(
        _ file: FileType,
        image: UIImage,
        imageRepresentation: ImageRepresentation = .png,
        ttl: TTL? = nil,
        completionHandler: ((Swift.Result<FileType, Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<FileType, Swift.Error>> {
        return upload(
            file,
            image: image,
            imageRepresentation: imageRepresentation,
            options: try! Options(ttl: ttl),
            completionHandler: completionHandler
        )
    }
    
    /// Uploads a `UIImage` in a PNG or JPEG format.
    @discardableResult
    open func upload(
        _ file: FileType,
        image: UIImage,
        imageRepresentation: ImageRepresentation = .png,
        options: Options? = nil,
        completionHandler: ((Swift.Result<FileType, Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<FileType, Swift.Error>> {
        let data = imageRepresentation.data(image: image)!
        file.mimeType = imageRepresentation.mimeType
        return upload(
            file,
            data: data,
            options: options,
            completionHandler: completionHandler
        )
    }

#endif
    
    /// Uploads a file using the file path.
    @discardableResult
    @available(*, deprecated, message: "Deprecated in version 3.17.0. Please use FileStore.upload(_:path:options:completionHandler:) instead")
    open func upload(
        _ file: FileType,
        path: String,
        ttl: TTL? = nil,
        completionHandler: FileCompletionHandler? = nil
    ) -> AnyRequest<Swift.Result<FileType, Swift.Error>> {
        return upload(
            file,
            path: path,
            ttl: ttl
        ) { (result: Swift.Result<FileType, Swift.Error>) in
            result.into(completionHandler: completionHandler)
        }
    }
    
    /// Uploads a file using the file path.
    @discardableResult
    @available(*, deprecated, message: "Deprecated in version 3.17.0. Please use FileStore.upload(_:path:options:completionHandler:) instead")
    open func upload(
        _ file: FileType,
        path: String,
        ttl: TTL? = nil,
        completionHandler: ((Swift.Result<FileType, Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<FileType, Swift.Error>> {
        return upload(
            file,
            path: path,
            options: try! Options(ttl: ttl),
            completionHandler: completionHandler
        )
    }
    
    /// Uploads a file using the file path.
    @discardableResult
    open func upload(
        _ file: FileType,
        path: String,
        options: Options? = nil,
        completionHandler: ((Swift.Result<FileType, Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<FileType, Swift.Error>> {
        return upload(
            file,
            fromSource: .url(URL(fileURLWithPath: (path as NSString).expandingTildeInPath)),
            options: options,
            completionHandler: completionHandler
        )
    }
    
    /// Uploads a file using a input stream.
    @discardableResult
    @available(*, deprecated, message: "Deprecated in version 3.17.0. Please use FileStore.upload(_:stream:options:completionHandler:) instead")
    open func upload(
        _ file: FileType,
        stream: InputStream,
        ttl: TTL? = nil,
        completionHandler: FileCompletionHandler? = nil
    ) -> AnyRequest<Swift.Result<FileType, Swift.Error>> {
        return upload(
            file,
            stream: stream,
            ttl: ttl
        ) { (result: Swift.Result<FileType, Swift.Error>) in
            result.into(completionHandler: completionHandler)
        }
    }
    
    /// Uploads a file using a input stream.
    @discardableResult
    @available(*, deprecated, message: "Deprecated in version 3.17.0. Please use FileStore.upload(_:stream:options:completionHandler:) instead")
    open func upload(
        _ file: FileType,
        stream: InputStream,
        ttl: TTL? = nil,
        completionHandler: ((Swift.Result<FileType, Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<FileType, Swift.Error>> {
        return upload(
            file,
            stream: stream,
            options: try! Options(ttl: ttl),
            completionHandler: completionHandler
        )
    }
    
    /// Uploads a file using a input stream.
    @discardableResult
    open func upload(
        _ file: FileType,
        stream: InputStream,
        options: Options? = nil,
        completionHandler: ((Swift.Result<FileType, Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<FileType, Swift.Error>> {
        return upload(
            file,
            fromSource: .stream(stream),
            options: options,
            completionHandler: completionHandler
        )
    }

    fileprivate func getFileMetadata<ResultType>(
        _ file: FileType,
        options: Options?,
        requests: MultiRequest<ResultType>?
    ) -> (request: AnyRequest<Swift.Result<FileType, Swift.Error>>, promise: Promise<FileType>) {
        let request = self.client.networkRequestFactory.blob.buildBlobDownloadFile(
            file,
            options: options,
            resultType: Swift.Result<FileType, Swift.Error>.self
        )
        let promise = Promise<FileType> { resolver in
            request.execute() { (data, response, error) -> Void in
                if let response = response, response.isOK,
                    let data = data,
                    let json = try? self.client.jsonParser.parseDictionary(from: data),
                    let newFile = FileType(JSON: json) {
                    newFile.path = file.path
                    if let cache = self.cache {
                        cache.save(newFile, beforeSave: nil)
                    }
                    
                    resolver.fulfill(newFile)
                } else {
                    resolver.reject(buildError(data, response, error, self.client))
                }
            }
            if let requests = requests {
                requests.progress.addChild(request.progress, withPendingUnitCount: 1)
                requests += request
            }
        }
        return (request: AnyRequest(request), promise: promise)
    }
    
    /// Uploads a file using a `NSData`.
    @discardableResult
    @available(*, deprecated, message: "Deprecated in version 3.17.0. Please use FileStore.upload(_:data:options:completionHandler:) instead")
    open func upload(
        _ file: FileType,
        data: Data,
        ttl: TTL? = nil,
        completionHandler: FileCompletionHandler? = nil
    ) -> AnyRequest<Swift.Result<FileType, Swift.Error>> {
        return upload(
            file,
            data: data,
            ttl: ttl
        ) { (result: Swift.Result<FileType, Swift.Error>) in
            result.into(completionHandler: completionHandler)
        }
    }
    
    /// Uploads a file using a `NSData`.
    @discardableResult
    @available(*, deprecated, message: "Deprecated in version 3.17.0. Please use FileStore.upload(_:data:options:completionHandler:) instead")
    open func upload(
        _ file: FileType,
        data: Data,
        ttl: TTL? = nil,
        completionHandler: ((Swift.Result<FileType, Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<FileType, Swift.Error>> {
        return upload(
            file,
            data: data,
            options: try! Options(ttl: ttl),
            completionHandler: completionHandler
        )
    }
    
    /// Uploads a file using a `NSData`.
    @discardableResult
    open func upload(
        _ file: FileType,
        data: Data,
        options: Options? = nil,
        completionHandler: ((Swift.Result<FileType, Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<FileType, Swift.Error>> {
        return upload(
            file,
            fromSource: .data(data),
            options: options,
            completionHandler: completionHandler
        )
    }
    
    fileprivate enum InputSource {
        
        case data(Data)
        case url(URL)
        case stream(InputStream)
        
    }
    
    @discardableResult
    open func create(
        _ file: FileType,
        data: Data,
        options: Options? = nil,
        completionHandler: ((Swift.Result<FileType, Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<FileType, Swift.Error>> {
        let requests = MultiRequest<Swift.Result<FileType, Swift.Error>>()
        createBucket(
            file,
            fromSource: .data(data),
            options: options,
            requests: requests
        ).done { (file, skip) -> Void in
            let result: Swift.Result<FileType, Swift.Error> = .success(file)
            requests.result = result
            completionHandler?(result)
        }.catch {
            let result: Swift.Result<FileType, Swift.Error> = .failure($0)
            requests.result = result
            completionHandler?(result)
        }
        return AnyRequest(requests)
    }
    
    @discardableResult
    open func create(
        _ file: FileType,
        path: String,
        options: Options? = nil,
        completionHandler: ((Swift.Result<FileType, Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<FileType, Swift.Error>> {
        let requests = MultiRequest<Swift.Result<FileType, Swift.Error>>()
        createBucket(
            file,
            fromSource: .url(URL(fileURLWithPath: (path as NSString).expandingTildeInPath)),
            options: options,
            requests: requests
        ).done { (file, skip) -> Void in
            let result: Swift.Result<FileType, Swift.Error> = .success(file)
            requests.result = result
            completionHandler?(result)
        }.catch {
            let result: Swift.Result<FileType, Swift.Error> = .failure($0)
            requests.result = result
            completionHandler?(result)
        }
        return AnyRequest(requests)
    }
    
    @discardableResult
    open func create(
        _ file: FileType,
        stream: InputStream,
        options: Options? = nil,
        completionHandler: ((Swift.Result<FileType, Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<FileType, Swift.Error>> {
        let requests = MultiRequest<Swift.Result<FileType, Swift.Error>>()
        createBucket(
            file,
            fromSource: .stream(stream),
            options: options,
            requests: requests
        ).done { (arg) -> Void in
            let (file, _) = arg
            let result: Swift.Result<FileType, Swift.Error> = .success(file)
            requests.result = result
            completionHandler?(result)
        }.catch {
            let result: Swift.Result<FileType, Swift.Error> = .failure($0)
            requests.result = result
            completionHandler?(result)
        }
        return AnyRequest(requests)
    }
    
    fileprivate func createBucket<ResultType>(
        _ file: FileType,
        fromSource source: InputSource,
        options: Options?,
        requests: MultiRequest<ResultType>
    ) -> Promise<(file: FileType, skip: Int?)> {
        return Promise<(file: FileType, skip: Int?)> { resolver in //creating bucket
            if file.size.value == nil {
                switch source {
                case let .data(data):
                    file.size.value = Int64(data.count)
                case let .url(url):
                    if let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
                        let fileSize = attrs[.size] as? Int64
                    {
                        file.size.value = fileSize
                    }
                default:
                    break
                }
            }
            
            let createUpdateFileEntry = {
                let request = self.client.networkRequestFactory.blob.buildBlobUploadFile(file, options: options)
                requests += request
                request.execute { (data, response, error) -> Void in
                    if let response = response, response.isOK,
                        let data = data,
                        let json = try? self.client.jsonParser.parseDictionary(from: data),
                        let newFile = FileType(JSON: json)
                    {
                        resolver.fulfill((file: newFile, skip: nil))
                    } else {
                        resolver.reject(buildError(data, response, error, self.client))
                    }
                }
            }
            
            guard let _ = file.fileId,
                let uploadURL = file.uploadURL
            else {
                createUpdateFileEntry()
                return
            }
            
            var request = URLRequest(url: uploadURL)
            request.httpMethod = "PUT"
            if let uploadHeaders = file.uploadHeaders {
                for (headerField, value) in uploadHeaders {
                    request.setValue(value, forHTTPHeaderField: headerField)
                }
            }
            request.setValue("0", forHTTPHeaderField: "Content-Length")
            switch source {
            case let .data(data):
                request.setValue("bytes */\(data.count)", forHTTPHeaderField: "Content-Range")
            case let .url(url):
                if let attrs = try? FileManager.default.attributesOfItem(atPath: (url.path as NSString).expandingTildeInPath),
                    let fileSize = attrs[FileAttributeKey.size] as? UInt64
                {
                    request.setValue("bytes */\(fileSize)", forHTTPHeaderField: "Content-Range")
                }
            case .stream:
                request.setValue("bytes */*", forHTTPHeaderField: "Content-Range")
            }
            
            if self.client.logNetworkEnabled {
                do {
                    log.debug("\(request.description)")
                }
            }
            
            let urlSession = options?.urlSession ?? client.urlSession
            let dataTask = urlSession.dataTask(with: request) { (data, response, error) in
                if self.client.logNetworkEnabled, let response = response as? HTTPURLResponse {
                    do {
                        log.debug("\(response.description(data))")
                    }
                }
                
                let regexRange = try! NSRegularExpression(pattern: "[bytes=]?(\\d+)-(\\d+)")
                if let response = response as? HTTPURLResponse, 200 <= response.statusCode && response.statusCode < 300 {
                    createUpdateFileEntry()
                } else if let response = response as? HTTPURLResponse,
                    response.statusCode == 308
                {
                    if let rangeString = response.allHeaderFields["Range"] as? String,
                        let textCheckingResult = regexRange.matches(in: rangeString, range: NSRange(location: 0, length: rangeString.count)).first,
                        textCheckingResult.numberOfRanges == 3
                    {
                        let endRangeString = rangeString.substring(with: textCheckingResult.range(at: 2))
                        if let endRange = Int(endRangeString) {
                            resolver.fulfill((file: file, skip: endRange))
                        } else {
                            resolver.reject(Error.invalidResponse(httpResponse: response, data: data))
                        }
                    } else {
                        resolver.fulfill((file: file, skip: nil))
                    }
                } else {
                    resolver.reject(buildError(data, HttpResponse(response: response), error, self.client))
                }
            }
            let urlSessionTaskRequest = URLSessionTaskRequest<ResultType>(client: client, options: options, task: dataTask)
            requests.progress.addChild(urlSessionTaskRequest.progress, withPendingUnitCount: 1)
            requests += urlSessionTaskRequest
            dataTask.resume()
        }
    }
    
    fileprivate func upload<ResultType>(
        _ file: FileType,
        fromSource source: InputSource,
        skip: Int?,
        options: Options?,
        requests: MultiRequest<ResultType>
    ) -> Promise<FileType> {
        return Promise<FileType> { resolver in
            var request = URLRequest(url: file.uploadURL!)
            request.httpMethod = "PUT"
            if let uploadHeaders = file.uploadHeaders {
                for (headerField, value) in uploadHeaders {
                    request.setValue(value, forHTTPHeaderField: headerField)
                }
            }
            
            let handler: (Data?, URLResponse?, Swift.Error?) -> Void = { data, response, error in
                if self.client.logNetworkEnabled, let response = response as? HTTPURLResponse {
                    do {
                        log.debug("\(response.description(data))")
                    }
                }
                
                if let response = response as? HTTPURLResponse, 200 <= response.statusCode && response.statusCode < 300 {
                    switch source {
                    case let .url(url):
                        file.path = url.path
                    default:
                        break
                    }
                    
                    resolver.fulfill(file)
                } else {
                    resolver.reject(buildError(data, HttpResponse(response: response), error, self.client))
                }
            }
            
            let urlSession = options?.urlSession ?? client.urlSession
            
            switch source {
            case let .data(data):
                let uploadData: Data
                if let skip = skip {
                    let startIndex = skip + 1
                    uploadData = data.subdata(in: startIndex ..< data.count - startIndex)
                    request.setValue("bytes \(startIndex)-\(data.count - 1)/\(data.count)", forHTTPHeaderField: "Content-Range")
                } else {
                    uploadData = data
                }
                
                if self.client.logNetworkEnabled {
                    do {
                        log.debug("\(request.description)")
                    }
                }
                
                let uploadTask = urlSession.uploadTask(with: request, from: uploadData) { (data, response, error) -> Void in
                    handler(data, response, error)
                }
                let urlSessionTaskRequest = URLSessionTaskRequest<ResultType>(client: self.client, options: options, task: uploadTask)
                requests.progress.addChild(urlSessionTaskRequest.progress, withPendingUnitCount: 98)
                requests += urlSessionTaskRequest
                uploadTask.resume()
            case let .url(url):
                if self.client.logNetworkEnabled {
                    do {
                        log.debug("\(request.description)")
                    }
                }
                
                let uploadTask = urlSession.uploadTask(with: request, fromFile: url) { (data, response, error) -> Void in
                    handler(data, response, error)
                }
                let urlSessionTaskRequest = URLSessionTaskRequest<ResultType>(client: self.client, options: options, task: uploadTask)
                requests.progress.addChild(urlSessionTaskRequest.progress, withPendingUnitCount: 98)
                requests += urlSessionTaskRequest
                uploadTask.resume()
            case let .stream(stream):
                request.httpBodyStream = stream
                
                if self.client.logNetworkEnabled {
                    do {
                        log.debug("\(request.description)")
                    }
                }
                
                let dataTask = urlSession.dataTask(with: request) { (data, response, error) -> Void in
                    handler(data, response, error)
                }
                let urlSessionTaskRequest = URLSessionTaskRequest<ResultType>(client: self.client, options: options, task: dataTask)
                requests.progress.addChild(urlSessionTaskRequest.progress, withPendingUnitCount: 98)
                requests += urlSessionTaskRequest
                dataTask.resume()
            }
        }
    }
    
    /// Uploads a file using a `NSData`.
    fileprivate func upload(
        _ file: FileType,
        fromSource source: InputSource,
        options: Options?,
        completionHandler: ((Swift.Result<FileType, Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<FileType, Swift.Error>> {
        let requests = MultiRequest<Swift.Result<FileType, Swift.Error>>()
        requests.progress = Progress(totalUnitCount: 100)
        createBucket(
            file,
            fromSource: source,
            options: options,
            requests: requests
        ).then { (args) -> Promise<FileType> in //uploading data
            let (file, skip) = args
            return self.upload(
                file,
                fromSource: source,
                skip: skip,
                options: options,
                requests: requests
            )
        }.then { file -> Promise<FileType> in //fetching download url
            let (_, promise) = self.getFileMetadata(
                file,
                options: options,
                requests: requests
            )
            return promise
        }.done { file -> Void in
            requests.progress.completedUnitCount = requests.progress.totalUnitCount
            let result: Swift.Result<FileType, Swift.Error> = .success(file)
            requests.result = result
            completionHandler?(result)
        }.catch { error in
            let result: Swift.Result<FileType, Swift.Error> = .failure(error)
            requests.result = result
            completionHandler?(result)
        }
        return AnyRequest(requests)
    }
    
    /// Refresh a `File` instance.
    @discardableResult
    @available(*, deprecated, message: "Deprecated in version 3.17.0. Please use FileStore.refresh(_:options:completionHandler:) instead")
    open func refresh(
        _ file: FileType,
        ttl: TTL? = nil,
        completionHandler: FileCompletionHandler? = nil
    ) -> AnyRequest<Swift.Result<FileType, Swift.Error>> {
        return refresh(
            file,
            ttl: ttl
        ) { (result: Swift.Result<FileType, Swift.Error>) in
            result.into(completionHandler: completionHandler)
        }
    }
    
    /// Refresh a `File` instance.
    @discardableResult
    @available(*, deprecated, message: "Deprecated in version 3.17.0. Please use FileStore.refresh(_:options:completionHandler:) instead")
    open func refresh(
        _ file: FileType,
        ttl: TTL? = nil,
        completionHandler: ((Swift.Result<FileType, Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<FileType, Swift.Error>> {
        return refresh(
            file,
            options: try! Options(ttl: ttl),
            completionHandler: completionHandler
        )
    }
    
    /// Refresh a `File` instance.
    @discardableResult
    open func refresh(
        _ file: FileType,
        options: Options? = nil,
        completionHandler: ((Swift.Result<FileType, Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<FileType, Swift.Error>> {
        let requests: MultiRequest<Swift.Result<FileType, Swift.Error>>? = nil
        let (request, promise) = getFileMetadata(
            file,
            options: options,
            requests: requests
        )
        promise.done { file in
            completionHandler?(.success(file))
        }.catch { error in
            completionHandler?(.failure(error))
        }
        return request
    }
    
    @discardableResult
    fileprivate func downloadFileURL(
        _ file: FileType,
        storeType: StoreType,
        downloadURL: URL,
        options: Options?
    ) -> (
        request: URLSessionTaskRequest<Swift.Result<URL, Swift.Error>>,
        promise: Promise<URL>
    ) {
        let downloadTaskRequest = URLSessionTaskRequest<Swift.Result<URL, Swift.Error>>(
            client: client,
            options: options,
            url: downloadURL
        )
        let promise = Promise<URL> { resolver in
            let executor = Executor()
            downloadTaskRequest.downloadTaskWithURL(file) { (url: URL?, _response, error) in
                guard let response = _response,
                    response.isOK || response.isNotModified,
                    let url = url
                else {
                    resolver.reject(buildError(nil, _response, error, self.client))
                    return
                }
                
                switch storeType {
                case .cache, .auto:
                    var pathURL: URL? = nil
                    var _entityId: String? = nil
                    executor.executeAndWait {
                        _entityId = file.fileId
                        pathURL = file.pathURL
                    }
                    if let pathURL = pathURL, response.isNotModified {
                        resolver.fulfill(pathURL)
                        return
                    }
                    
                    let fileManager = FileManager()
                    guard let entityId = _entityId else {
                        resolver.reject(Error.invalidResponse(httpResponse: response.httpResponse, data: nil))
                        return
                    }
                    
                    let baseFolder = cacheBasePath
                    do {
                        var baseFolderURL = URL(fileURLWithPath: baseFolder)
                        baseFolderURL = baseFolderURL.appendingPathComponent(self.client.appKey!).appendingPathComponent("files")
                        if !fileManager.fileExists(atPath: baseFolderURL.path) {
                            try fileManager.createDirectory(at: baseFolderURL, withIntermediateDirectories: true, attributes: nil)
                        }
                        let toURL = baseFolderURL.appendingPathComponent(entityId)
                        if fileManager.fileExists(atPath: toURL.path) {
                            do {
                                try fileManager.removeItem(atPath: toURL.path)
                            }
                        }
                        try fileManager.moveItem(at: url, to: toURL)
                        
                        if let cache = self.cache {
                            cache.save(file) {
                                file.path = NSString(string: toURL.path).abbreviatingWithTildeInPath
                                file.etag = response.etag
                            }
                        }
                        
                        resolver.fulfill(toURL)
                    } catch let error {
                        resolver.reject(error)
                    }
                default:
                    resolver.fulfill(url)
                }
            }
        }
        return (request: downloadTaskRequest, promise: promise)
    }
    
    @discardableResult
    fileprivate func downloadFileData(_ file: FileType, downloadURL: URL, options: Options?) -> (request: URLSessionTaskRequest<Any>, promise: Promise<Data>) {
        let downloadTaskRequest = URLSessionTaskRequest<Any>(client: client, options: options, url: downloadURL)
        let promise = downloadTaskRequest.downloadTaskWithURL(file).then { (arg) -> Promise<Data> in
            let (data, _) = arg
            return Promise<Data>.value(data)
        }
        return (request: downloadTaskRequest, promise: promise)
    }
    
    /// Returns the cached file, if exists.
    open func cachedFile(_ entityId: String) -> FileType? {
        return cache?.get(entityId)
    }
    
    /// Returns the cached file, if exists.
    open func cachedFile(_ file: FileType) throws -> FileType? {
        let entityId = try crashIfInvalid(file: file)
        return cachedFile(entityId)
    }
    
    @discardableResult
    fileprivate func crashIfInvalid(file: FileType) throws -> String {
        guard let fileId = file.fileId else {
            throw Error.invalidOperation(description: "fileId is required")
        }
        return fileId
    }
    
    /// Downloads a file using the `downloadURL` of the `File` instance.
    @discardableResult
    @available(*, deprecated, message: "Deprecated in version 3.17.0. Please use FileStore.download(_:storeType:options:completionHandler:) instead")
    open func download(
        _ file: FileType,
        storeType: StoreType = .cache,
        ttl: TTL? = nil,
        completionHandler: FilePathCompletionHandler? = nil
    ) -> AnyRequest<Swift.Result<(FileType, URL), Swift.Error>> {
        return download(
            file,
            storeType: storeType,
            ttl: ttl
        ) { (result: Swift.Result<(FileType, URL), Swift.Error>) in
            result.into(completionHandler: completionHandler)
        }
    }
    
    /// Downloads a file using the `downloadURL` of the `File` instance.
    @discardableResult
    @available(*, deprecated, message: "Deprecated in version 3.17.0. Please use FileStore.download(_:storeType:options:completionHandler:) instead")
    open func download(
        _ file: FileType,
        storeType: StoreType = .cache,
        ttl: TTL? = nil,
        completionHandler: ((Swift.Result<(FileType, URL), Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<(FileType, URL), Swift.Error>> {
        return download(
            file,
            storeType: storeType,
            options: try! Options(ttl: ttl),
            completionHandler: completionHandler
        )
    }
    
    /// Downloads a file using the `downloadURL` of the `File` instance.
    @available(*, deprecated, message: "Deprecated in version 3.21.0. Please use `download(file:storeType:options:completionHandler:)` instead")
    @discardableResult
    open func download(
        _ file: FileType,
        storeType: StoreType = .cache,
        options: Options? = nil,
        completionHandler: ((Swift.Result<(FileType, URL), Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<(FileType, URL), Swift.Error>> {
        return download(
            file: file,
            storeType: storeType,
            options: options,
            completionHandler: completionHandler
        )
    }
    
    /// Downloads a file using the `downloadURL` of the `File` instance.
    @discardableResult
    open func download(
        file: FileType,
        storeType: StoreType,
        options: Options? = nil,
        completionHandler: ((Swift.Result<(FileType, URL), Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<(FileType, URL), Swift.Error>> {
        do {
            try crashIfInvalid(file: file)
        } catch {
            return errorRequest(error: error, completionHandler: completionHandler)
        }
        
        switch storeType {
        case .sync, .cache:
            if let entityId = file.fileId,
                let cachedFile = cachedFile(entityId),
                let pathURL = cachedFile.pathURL
            {
                let result: Swift.Result<(FileType, URL), Swift.Error> = .success((cachedFile, pathURL))
                DispatchQueue.main.async {
                    completionHandler?(result)
                }
                
                if storeType == .sync {
                    return AnyRequest(LocalRequest(result))
                }
            }
        default:
            break
        }
        
        switch storeType {
        case .cache, .network, .auto:
            let multiRequest = MultiRequest<Swift.Result<(FileType, URL), Swift.Error>>()
            Promise<(FileType, URL)> { resolver in
                if let downloadURL = file.downloadURL,
                    file.publicAccessible ||
                    (
                        file.expiresAt != nil &&
                        file.expiresAt!.timeIntervalSinceNow > 0
                    )
                {
                    resolver.fulfill((file, downloadURL))
                } else {
                    let (_, promise) = getFileMetadata(
                        file,
                        options: options,
                        requests: multiRequest
                    )
                    promise.done { (file) -> Void in
                        if let downloadURL = file.downloadURL {
                            resolver.fulfill((file, downloadURL))
                        } else {
                            throw Error.invalidResponse(httpResponse: nil, data: nil)
                        }
                    }.catch { error in
                        resolver.reject(error)
                    }
                }
            }.then { (file, downloadURL) -> Promise<(FileType, URL)> in
                let (request, promise) = self.downloadFileURL(
                    file,
                    storeType: storeType,
                    downloadURL: downloadURL,
                    options: options
                )
                multiRequest += request
                return promise.then { localUrl in
                    return Promise<(FileType, URL)>.value((file, localUrl))
                }
            }.recover { (error) -> Promise<(FileType, URL)> in
                if storeType == .auto,
                    let entityId = file.fileId,
                    let cachedFile = self.cachedFile(entityId),
                    let pathURL = file.pathURL
                {
                    return Promise(Guarantee { seal in
                        seal((cachedFile, pathURL))
                    })
                } else {
                    return Promise(error: error)
                }
            }.done { (args) -> Void in
                let result: Swift.Result<(FileType, URL), Swift.Error> = .success(args)
                multiRequest.result = result
                completionHandler?(result)
            }.catch { (error) -> Void in
                let result: Swift.Result<(FileType, URL), Swift.Error> = .failure(error)
                multiRequest.result = result
                completionHandler?(result)
            }
            return AnyRequest(multiRequest)
        default:
            let msg = "File not found"
            let result: Swift.Result<(FileType, URL), Swift.Error> = .failure(Error.entityNotFound(debug: msg, description: msg))
            completionHandler?(result)
            return AnyRequest(LocalRequest(result))
        }
    }
    
    /// Downloads a file using the `downloadURL` of the `File` instance.
    @discardableResult
    @available(*, deprecated, message: "Deprecated in version 3.17.0. Please use FileStore.download(_:options:completionHandler:) instead")
    open func download(
        _ file: FileType,
        ttl: TTL? = nil,
        completionHandler: FileDataCompletionHandler? = nil
    ) -> AnyRequest<Swift.Result<(FileType, Data), Swift.Error>> {
        return download(
            file,
            ttl: ttl
        ) { (result: Swift.Result<(FileType, Data), Swift.Error>) in
            result.into(completionHandler: completionHandler)
        }
    }
    
    private enum DownloadStage {
        
        case downloadURL(URL)
        case data(Data)
        
    }
    
    /// Downloads a file using the `downloadURL` of the `File` instance.
    @discardableResult
    @available(*, deprecated, message: "Deprecated in version 3.17.0. Please use FileStore.download(_:options:completionHandler:) instead")
    open func download(
        _ file: FileType,
        ttl: TTL? = nil,
        completionHandler: ((Swift.Result<(FileType, Data), Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<(FileType, Data), Swift.Error>> {
        return download(
            file,
            options: try! Options(ttl: ttl),
            completionHandler: completionHandler
        )
    }
    
    /// Downloads a file using the `downloadURL` of the `File` instance.
    @discardableResult
    open func download(
        _ file: FileType,
        options: Options? = nil,
        completionHandler: ((Swift.Result<(FileType, Data), Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<(FileType, Data), Swift.Error>> {
        do {
            try crashIfInvalid(file: file)
        } catch {
            return errorRequest(error: error, completionHandler: completionHandler)
        }
        
        let multiRequest = MultiRequest<Swift.Result<(FileType, Data), Swift.Error>>()
        multiRequest.progress = Progress(totalUnitCount: 100)
        Promise<(FileType, DownloadStage)> { resolver in
            if let entityId = file.fileId,
                let cachedFile = cachedFile(entityId),
                let path = file.path,
                let data = try? Data(contentsOf: URL(fileURLWithPath: path))
            {
                resolver.fulfill((cachedFile, .data(data)))
                return
            }
            
            if let downloadURL = file.downloadURL,
                file.publicAccessible ||
                (
                    file.expiresAt != nil &&
                    file.expiresAt!.timeIntervalSinceNow > 0
                )
            {
                resolver.fulfill((file, .downloadURL(downloadURL)))
            } else {
                let (_, promise) = getFileMetadata(
                    file,
                    options: options,
                    requests: multiRequest
                )
                promise.done { file in
                    if let downloadURL = file.downloadURL,
                        file.publicAccessible ||
                        (
                            file.expiresAt != nil &&
                            file.expiresAt!.timeIntervalSinceNow > 0
                        )
                    {
                        resolver.fulfill((file, .downloadURL(downloadURL)))
                    } else {
                        throw Error.invalidResponse(httpResponse: nil, data: nil)
                    }
                }.catch { error in
                    resolver.reject(error)
                }
            }
        }.then { (args) -> Promise<(FileType, FileStore<FileType>.DownloadStage)> in
            multiRequest.progress.completedUnitCount = 1
            return Promise<(FileType, DownloadStage)>.value(args)
        }.then { (file, downloadStage) -> Promise<Data> in
            switch downloadStage {
            case .downloadURL(let downloadURL):
                let (request, promise) = self.downloadFileData(
                    file,
                    downloadURL: downloadURL,
                    options: options
                )
                multiRequest.progress.addChild(request.progress, withPendingUnitCount: 99)
                multiRequest += request
                return promise
            case .data(let data):
                return Promise<Data>.value(data)
            }
        }.done { data in
            multiRequest.progress.completedUnitCount = multiRequest.progress.totalUnitCount
            let result: Swift.Result<(FileType, Data), Swift.Error> = .success((file, data))
            multiRequest.result = result
            completionHandler?(result)
        }.catch { error in
            let result: Swift.Result<(FileType, Data), Swift.Error> = .failure(error)
            multiRequest.result = result
            completionHandler?(result)
        }
        return AnyRequest(multiRequest)
    }
    
    /// Deletes a file instance in the backend.
    @discardableResult
    @available(*, deprecated, message: "Deprecated in version 3.17.0. Please use FileStore.remove(_:options:completionHandler:) instead")
    open func remove(
        _ file: FileType,
        completionHandler: UIntCompletionHandler? = nil
    ) -> AnyRequest<Swift.Result<UInt, Swift.Error>> {
        return remove(
            file,
            options: nil
        ) { (result: Swift.Result<UInt, Swift.Error>) in
            result.into(completionHandler: completionHandler)
        }
    }
    
    /// Deletes a file instance in the backend.
    @discardableResult
    @available(*, deprecated, message: "Deprecated in version 3.17.0. Please use FileStore.remove(_:options:completionHandler:) instead")
    open func remove(
        _ file: FileType,
        completionHandler: ((Swift.Result<UInt, Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<UInt, Swift.Error>> {
        return remove(
            file,
            options: nil,
            completionHandler: completionHandler
        )
    }
    
    /// Deletes a file instance in the backend.
    @discardableResult
    open func remove(
        _ file: FileType,
        options: Options? = nil,
        completionHandler: ((Swift.Result<UInt, Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<UInt, Swift.Error>> {
        let request = client.networkRequestFactory.blob.buildBlobDeleteFile(
            file,
            options: options,
            resultType: Swift.Result<UInt, Swift.Error>.self
        )
        Promise<UInt> { resolver in
            request.execute({ (data, response, error) -> Void in
                if let response = response, response.isOK,
                    let data = data,
                    let json = try? self.client.jsonParser.parseDictionary(from: data),
                    let count = json["count"] as? UInt
                {
                    if let cache = self.cache {
                        cache.remove(file)
                    }
                    
                    resolver.fulfill(count)
                } else {
                    resolver.reject(buildError(data, response, error, self.client))
                }
            })
        }.done {
            completionHandler?(.success($0))
        }.catch {
            completionHandler?(.failure($0))
        }
        return AnyRequest(request)
    }
    
    /// Gets a list of files that matches with the query passed by parameter.
    @discardableResult
    @available(*, deprecated, message: "Deprecated in version 3.17.0. Please use FileStore.find(_:options:completionHandler:) instead")
    open func find(
        _ query: Query = Query(),
        ttl: TTL? = nil,
        completionHandler: FileArrayCompletionHandler? = nil
    ) -> AnyRequest<Swift.Result<[FileType], Swift.Error>> {
        return find(
            query,
            ttl: ttl
        ) { (result: Swift.Result<[FileType], Swift.Error>) in
            result.into(completionHandler: completionHandler)
        }
    }
    
    /// Gets a list of files that matches with the query passed by parameter.
    @discardableResult
    @available(*, deprecated, message: "Deprecated in version 3.17.0. Please use FileStore.find(_:options:completionHandler:) instead")
    open func find(
        _ query: Query = Query(),
        ttl: TTL? = nil,
        completionHandler: ((Swift.Result<[FileType], Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<[FileType], Swift.Error>> {
        return find(
            query,
            options: try! Options(ttl: ttl),
            completionHandler: completionHandler
        )
    }
    
    /// Gets a list of files that matches with the query passed by parameter.
    @discardableResult
    open func find(
        _ query: Query = Query(),
        options: Options? = nil,
        completionHandler: ((Swift.Result<[FileType], Swift.Error>) -> Void)? = nil
    ) -> AnyRequest<Swift.Result<[FileType], Swift.Error>> {
        let request = client.networkRequestFactory.blob.buildBlobQueryFile(
            query,
            options: options,
            resultType: Swift.Result<[FileType], Swift.Error>.self
        )
        Promise<[FileType]> { resolver in
            request.execute { (data, response, error) -> Void in
                if let response = response,
                    response.isOK,
                    let data = data,
                    let jsonArray = try? self.client.jsonParser.parseDictionaries(from: data)
                {
                    let files = [FileType](JSONArray: jsonArray)
                    resolver.fulfill(files)
                } else {
                    resolver.reject(buildError(data, response, error, self.client))
                }
            }
        }.done { files in
            completionHandler?(.success(files))
        }.catch { error in
            completionHandler?(.failure(error))
        }
        return AnyRequest(request)
    }
    
    /**
     Clear cached files from local storage.
     */
    open func clearCache() {
        client.cacheManager.clearAll()
    }
    
}
