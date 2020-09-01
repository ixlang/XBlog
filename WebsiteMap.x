//xlang Source, Name:WebsiteMap.x 
//Date: Sat May 15:23:25 2020 

class WebsiteMap : HttpServlet{

    public WebsiteMap() {//构造
		super(0, "/sitemap.html");

	}
    
	void doGet(HttpServletRequest request, HttpServletResponse response) override {
		String sitemap = ArticleCacher.webSiteMap();
        if (sitemap != nilptr){
            response.print(sitemap);
        }else{
            response.print("has no website map");
        }
	}
};