//xlang Source, Name:ArticleView.x 
//Date: Sat May 13:37:13 2020 

class ArticleView : HttpServlet{

    static String template = nilptr;
    static String admin_template = nilptr;
    static bool bool_temp_loaded = false;
    
    void loadTemplate(){
        bool_temp_loaded = true;
        FileInputStream fis ;
        try{
            fis = new FileInputStream(XBlog.getWwwroot().appendPath("article.temp"));
            byte [] data = fis.read();
            template = new String(data);
        }catch(Exception e){
            
        }finally{
            if (fis != nilptr){
                fis.close();
                fis = nilptr;
            }
        }
        
        try{
            fis = new FileInputStream(XBlog.getWwwroot().appendPath("article.html"));
            byte [] data = fis.read();
            admin_template = new String(data);
        }catch(Exception e){
            
        }finally{
            if (fis != nilptr){
                fis.close();
                fis = nilptr;
            }
        }
    }
    
    public ArticleView() {//构造
		super(0, "/article.html");
        if (bool_temp_loaded == false){
            loadTemplate();
        }
	}
    
    String hexString(String text){
        String out = "";
        for (int i = 0; i < text.length(); i++){
            out = out + "," + String.format("%d",text.charAt(i));
        }
        if (out.length() > 0){
            return "[" + out.substring(1, out.length()) + "]";
        }
        return "[]";
    }
    
    void buildStaticPage(int artid, String title, String category, String content, String date,  JsonObject prev , JsonObject post, JsonArray comments, HttpServletResponse response){
        if (template == nilptr){
            return;
        }
        
        String prevTitle = nilptr, prevHref = nilptr, postTitle = nilptr, postHref = nilptr;
        int pr = 0, po = 0;
        if (prev != nilptr){
            prevTitle = prev.getString("name");
            pr = prev.getInt("id");
            prevHref = "article.html?id=" + pr;
        }else{
            prevHref = "#";
            prevTitle = "没有上一篇";
        }
        
        if (post != nilptr){
            postTitle = post.getString("name");
            po = post.getInt("id");
            postHref = "article.html?id=" + po;
        }else{
            postHref = "#";
            postTitle = "没有下一篇";
        }
        
        String cmtData = "[]";
        if (comments != nilptr){
            cmtData = comments.toString(false);
        }
        
        String cmtdata = hexString(cmtData);
        
        String html_content = template.replace("${ArticleId}","" + artid)
            .replace("${Title}",title)
            .replace("${Content}",content)
            .replace("${Category}",category)
            .replace("${Timestamp}", date)
            .replace("${PreTitle}",prevTitle)
            .replace("${PreArticle}",prevHref)
            .replace("${PostTitle}",postTitle)
            .replace("${PostArticle}",postHref)
            .replace("${CommentData}","var cmtData = " + cmtdata);
            
        response.print(html_content);
        
        ArticleCacher.makeCache(artid , title,html_content, pr, po, false);
    }
    
	void doGet(HttpServletRequest request, HttpServletResponse response) override {
		//TODO:	
        bool editable = false;
        String suid = request.getSession("id");
        
        if (suid != nilptr){
            if (suid.parseInt() > 0){
                if (admin_template != nilptr){
                    response.print(admin_template);
                }else{
                    response.print("can't display this article");
                }
                return;
            }
        }
        
        String stractid = request.getArg("id");
        int actid = 0;
        if (stractid != nilptr){
            actid = stractid.parseInt();
        }
    
        if (actid < 0){
            actid = 0;
        }
        
        String strcategoryid = request.getArg("category");
        int categoryid = 0;
        if (strcategoryid != nilptr){
            categoryid = strcategoryid.parseInt();
        }
    
        if (categoryid < 0){
            categoryid = 0;
        }
        
        String content = ArticleCacher.loadCache(actid);
        
        if (content == nilptr){
            JsonObject root = ListArticle.readArticle(actid, categoryid, editable);
            int error = root.getInt("error");
            
            if (error == 0){
                error = -1;
                JsonArray arts = (JsonArray)root.get("data");
                if (arts != nilptr && arts.length() > 0){
                    JsonObject art = (JsonObject)arts.get(0);
                    if (art != nilptr){
                    
                        buildStaticPage(
                            art.getInt("id"), 
                            art.getString("name"), 
                            art.getString("category"), 
                            art.getString("content"), 
                            art.getString("date"),
                            (JsonObject) root.get("prev"), 
                            (JsonObject)root.get("post"), 
                            (JsonArray)art.get("comments"),
                            response);
                        error = 0;
                    }
                }
            }
            if (error != 0){
                response.print("can't display this article");
            }
        }else{
            response.print(content);
        }
	}
};