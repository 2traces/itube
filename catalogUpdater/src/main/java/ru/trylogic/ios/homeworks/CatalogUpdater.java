package ru.trylogic.ios.homeworks;

import org.w3c.dom.Document;

import javax.swing.*;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.*;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import java.io.File;
import java.io.FilenameFilter;
import java.util.Arrays;
import java.util.Comparator;
import java.util.regex.Pattern;

import org.apache.xpath.NodeSet;
import org.w3c.dom.Element;

public class CatalogUpdater implements Runnable {

    public static final String sourceDirectory = "homeworks";

    public static void main(String[] args) throws Exception {
        
        try {
            (new CatalogUpdater()).run();
        } catch (Exception e) {
            JOptionPane.showMessageDialog(null, e.getMessage());
        }
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
        System.out.println("getList for " + termId + "/" + subjectId + "/" + bookId);
        NodeSet nodeSet = new NodeSet();
        
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        DocumentBuilder docBuilder = dbf.newDocumentBuilder();
        Document document = docBuilder.newDocument();
        
        File answersDirectory = new File("." + File.separator + sourceDirectory + File.separator + termId + File.separator + subjectId + File.separator + bookId);
        
        if(!answersDirectory.exists()) {
            return nodeSet;
        }
        
        String[] answers = answersDirectory.list(new FilenameFilter() {
            @Override
            public boolean accept(File file, String s) {
                return new File(file, s).isFile();
            }
        });
        Arrays.sort(answers, new Comparator<String>(){
            public int compare(String f1, String f2)
            {
                return normalisedVersion(f1).compareTo(normalisedVersion(f2));
            } });
        
        for (String answer : answers){
            int lastDotIndex = answer.lastIndexOf(".");
            String fileName = answer.substring(0, lastDotIndex);
            String fileExt = answer.substring(lastDotIndex + 1);
            if(fileName.equalsIgnoreCase("cover")) {
                continue;
            }
            Element answerElement = document.createElement("answer");
            answerElement.setAttribute("file", fileName);
            answerElement.setAttribute("ext", fileExt);
            nodeSet.addElement(answerElement);
        }

        return nodeSet;
    }

    @Override
    public void run() {
        try {
            TransformerFactory factory = TransformerFactory.newInstance();
            Source xslt = new StreamSource(CatalogUpdater.class.getClassLoader().getResourceAsStream("transform.xsl"));
            Transformer transformer = factory.newTransformer(xslt);
            transformer.setErrorListener(new ErrorListener() {
                @Override
                public void warning(TransformerException e) throws TransformerException {
                    //To change body of implemented methods use File | Settings | File Templates.
                }

                @Override
                public void error(TransformerException e) throws TransformerException {
                    e.printStackTrace();
                }

                @Override
                public void fatalError(TransformerException e) throws TransformerException {
                    e.printStackTrace();
                }
            });

            Source text = new StreamSource(new File("input.xml"));
            
            transformer.transform(text, new StreamResult("catalog.xml"));

            JOptionPane.showMessageDialog(null, "Done");
        } catch (Exception e) {
            JOptionPane.showMessageDialog(null, e.getMessage());
        }
    }
}
