package ru.trylogic.ios.homeworks;

import org.apache.commons.lang.StringUtils;

import javax.swing.*;
import javax.xml.parsers.*;
import java.io.*;
import java.util.Arrays;
import java.util.Comparator;
import java.util.regex.Pattern;

import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

public class CatalogUpdater extends DefaultHandler implements Runnable {

    public static final String sourceDirectory = "homeworks";
    private OutputStream outputStream;
    private String currentTerm;
    private String currentSubject;
    private int indentLevel = 0;

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

    @Override
    public void run() {
        try {
            SAXParserFactory factory = SAXParserFactory.newInstance();
            SAXParser saxParser = factory.newSAXParser();

            outputStream = new FileOutputStream(new File(sourceDirectory, "catalog.xml"));

            InputStream inputStream = new FileInputStream(new File("input.xml"));
            Reader reader = new InputStreamReader(inputStream, "UTF-8");

            InputSource is = new InputSource(reader);
            is.setEncoding("UTF-8");
            saxParser.parse(is, this);

            JOptionPane.showMessageDialog(null, "Done");
        } catch (Exception e) {
            e.printStackTrace();
            JOptionPane.showMessageDialog(null, e.getMessage());
        }
    }

    @Override
    public void startElement(String uri, String localName, String qName,
                             Attributes attributes) throws SAXException {

        try {

            StringBuilder s = new StringBuilder();
            s.append(StringUtils.repeat("\t", indentLevel));
            s.append("<");
            s.append(qName);

            for (int i = 0; i < attributes.getLength(); i++) {
                s.append(" ");
                s.append(attributes.getQName(i));
                s.append("=\"");
                s.append(attributes.getValue(i));
                s.append("\"");
            }


            String id = attributes.getValue("id");

            if (qName.equalsIgnoreCase("term")) {
                currentTerm = id;
                s.append(">\n");
            } else if (qName.equalsIgnoreCase("subject")) {
                currentSubject = id;
                s.append(">\n");
            } else if (qName.equalsIgnoreCase("book")) {

                File answersDirectory = new File("." + File.separator + sourceDirectory + File.separator + currentTerm + File.separator + currentSubject + File.separator + id);

                System.out.println("getList for " + answersDirectory.getAbsolutePath());

                if (answersDirectory.exists()) {

                    String[] answers = answersDirectory.list(new FilenameFilter() {
                        @Override
                        public boolean accept(File dir, String fileName) {
                            return new File(dir, fileName).isFile() && fileName.contains(".");
                        }
                    });
                    Arrays.sort(answers, new Comparator<String>() {
                        public int compare(String f1, String f2) {
                            return normalisedVersion(f1).compareTo(normalisedVersion(f2));
                        }
                    });

                    Boolean extAppended = false;
                    for (String answer : answers) {
                        int lastDotIndex = answer.lastIndexOf(".");
                        String fileName = answer.substring(0, lastDotIndex);
                        if (fileName.equalsIgnoreCase("cover")) {
                            continue;
                        }
                        String fileExt = answer.substring(lastDotIndex + 1);

                        if (!extAppended) {
                            s.append(" ext=\"");
                            s.append(fileExt);
                            s.append("\">\n");
                            extAppended = true;
                        }

                        s.append(StringUtils.repeat("\t", indentLevel + 1));
                        s.append("<a>");
                        s.append(fileName);
                        s.append("</a>\n");
                    }

                    if (!extAppended) {
                        s.append(">\n");
                    }
                } else {
                    s.append(">\n");
                }
            } else {
                s.append(">\n");
            }

            indentLevel++;
            outputStream.write(s.toString().getBytes("utf-8"));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void endElement(String uri, String localName,
                           String qName) throws SAXException {
        try {
            indentLevel--;
            String s = StringUtils.repeat("\t", indentLevel) + "</" + qName + ">\n";
            outputStream.write(s.getBytes());
            outputStream.flush();
        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    @Override
    public void endDocument() throws org.xml.sax.SAXException {
        try {
            outputStream.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

}
