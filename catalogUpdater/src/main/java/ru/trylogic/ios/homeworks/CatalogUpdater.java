package ru.trylogic.ios.homeworks;

import org.w3c.dom.Document;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import java.io.File;
import java.util.Arrays;
import java.util.Comparator;
import java.util.regex.Pattern;

import org.apache.xpath.NodeSet;

public class CatalogUpdater implements Runnable {

    public static final String sourceDirectory = "homeworks";

    public static void main(String[] args) throws Exception {
        (new CatalogUpdater()).run();
    }



    public static String normalisedVersion(String version) {
        return normalisedVersion(version, ".", 4);
    }

    public static String normalisedVersion(String version, String sep, int maxWidth) {
        String[] split = Pattern.compile(sep, Pattern.LITERAL).split(version);
        StringBuilder sb = new StringBuilder();
        for (String s : split) {
            sb.append(String.format("%" + maxWidth + 's', s));
        }
        return sb.toString();
    }

    public static NodeSet getList(String termId, String subjectId, String bookId) throws ParserConfigurationException {
        NodeSet nodeSet = new NodeSet();
        
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        DocumentBuilder docBuilder = dbf.newDocumentBuilder();
        Document document = docBuilder.newDocument();
        
        File answersDirectory = new File("." + File.separator + sourceDirectory + File.separator + termId + File.separator + subjectId + File.separator + bookId);
        
        String[] answers = answersDirectory.list();
        Arrays.sort(answers, new Comparator<String>(){
            public int compare(String f1, String f2)
            {
                return normalisedVersion(f1).compareTo(normalisedVersion(f2));
            } });
        
        for (String answer : answers){
            nodeSet.addElement(document.createTextNode(answer));
        }

        return nodeSet;
    }

    @Override
    public void run() {
        try {
            TransformerFactory factory = TransformerFactory.newInstance();
            Source xslt = new StreamSource(CatalogUpdater.class.getClassLoader().getResourceAsStream("transform.xsl"));
            Transformer transformer = factory.newTransformer(xslt);

            Source text = new StreamSource(new File("input.xml"));
            
            transformer.transform(text, new StreamResult("catalog.xml"));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
