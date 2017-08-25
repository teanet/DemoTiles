import MapKit

internal class DGSTileOverlay: MKTileOverlay {

	private let cache = NSCache<NSURL, NSData>()
	private let urlSession = URLSession(configuration: URLSessionConfiguration.default)

	override func url(forTilePath path: MKTileOverlayPath) -> URL {
		return URL(string: String(format: "https://tile2.maps.2gis.com/tiles?x=%d&y=%d&z=%d&v=1", path.x, path.y, path.z))!
	}

	internal init() {
		super.init(urlTemplate: "https://tile2.maps.2gis.com/tiles?x={x}&y={y}&z={z}&v=1")
		self.canReplaceMapContent = true
		self.maximumZ = 18
	}

	override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
		let url = self.url(forTilePath: path)
		if let cachedData = self.cache.object(forKey: url as NSURL) as Data? {
			result(cachedData, nil)
		} else {
			let task = self.urlSession.dataTask(with: url, completionHandler: {
				[weak self] (data, response, error) in
				if let data = data {
					self?.cache.setObject(data as NSData, forKey: url as NSURL)
				}
				result(data, error)
			})
			task.resume()
		}
	}

}

