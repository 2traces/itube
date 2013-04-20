package ru.trylogic.ios.homeworks;

import ru.trylogic.ios.homeworks.CatalogUpdater;

/**
 * Created with IntelliJ IDEA.
 * User: bsideup
 * Date: 4/19/13
 * Time: 1:26 PM
 * To change this template use File | Settings | File Templates.
 */
public class Starter {
    
    public static void main(String[] args) throws Exception {

        //String pathToJar = CatalogUpdater.class.getProtectionDomain().getCodeSource().getLocation().toURI().getPath();
        //ProcessBuilder pb = new ProcessBuilder("java","-Xmx1024m", "-classpath", pathToJar, "ru.trylogic.ios.homeworks.CatalogUpdater");
        //pb.start();
        
        CatalogUpdater.main(args);
    }
}
