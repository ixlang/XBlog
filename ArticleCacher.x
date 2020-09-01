//xlang Source, Name:ArticleCacher.x 
//Date: Sat May 13:59:29 2020 

class ArticleCacher{
    public static Object _cacheLock = new Object();
    public static String sitemap;
    
    static class Content{
        public String content;
        public int prev, post;
        public String title;
        
        public Content(String _title, String con, int pr, int po){
            content = con;
            title = _title;
            prev = pr;
            post = po;
        }
    };
    
    static Map<int, Content> __articleCache = new Map<int, Content>();
    
    public static void refreshnear(int id){
        if (id > 0){
            int prev = ListArticle.getNear(id,0,true);
            if (prev > 0){
                makeCache(prev, nilptr, nilptr, 0, 0, true);
            }
            
            int next = ListArticle.getNear(id,0,false);
            if (next > 0){
                makeCache(next, nilptr, nilptr, 0, 0, true);
            }
        }
    }
    
    public static void makeCache(int id, String title, String content,int pr, int po, bool remove){
        synchronized(_cacheLock){
            if (remove == false){
                __articleCache.put(id, new Content(title, content, pr, po));
                sitemap = nilptr;
            }else{
               Map.Iterator<int, Content> artit = __articleCache.find(id);
               if (artit != nilptr){
                   Content co = artit.getValue();
                   __articleCache.remove(id);
                   
                   if (co.prev != 0){
                        __articleCache.remove(co.prev);
                   }
                   
                   if (co.post != 0){
                        __articleCache.remove(co.post);
                   }
                   sitemap = nilptr;
               }
            }
        }
    }
    
    public static String loadCache(int id){
        synchronized(_cacheLock){
           Map.Iterator<int, Content> artit = __articleCache.find(id);
           if (artit != nilptr){
               Content co = artit.getValue();
               return co.content;
           }
        }
        return nilptr;
    }
    
    public static String webSiteMap(){
    
        synchronized(_cacheLock){
            if (sitemap == nilptr){
                String mapstring = "<!DOCTYPE html><html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /><title>快速检索 - 网站地图</title></head><body>";
                Map.Iterator<int, Content> iter = __articleCache.iterator();
                while (iter.hasNext()){
                    Content co = iter.getValue();
                    mapstring = mapstring + "<a href=\"article.html?id=" + iter.getKey() + "\" >" + co.title  + "</a><br />\n";
                    iter.next();
                }
                sitemap = mapstring + "<p>	&copy; Cadaqs 2019 <strong>xlang2.7</strong> </p> </body></html>";
            }
            
            return sitemap;
        }
    }
};