package org.support.project.common.serialize.impl;

import java.io.ByteArrayInputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;

import com.fasterxml.jackson.dataformat.xml.XmlMapper;
import org.support.project.common.exception.SerializeException;
import org.support.project.common.log.Log;
import org.support.project.common.log.LogFactory;


/**
 * XMLとオブジェクトの変換をJackson XMLを用いて実施する
 * @author Koda
 *
 */
public class SerializerForXmlOnSimpleImpl implements org.support.project.common.serialize.Serializer {
	/** ログ */
	private static final Log LOG = LogFactory.getLog(SerializerForXmlOnSimpleImpl.class);

	private static final XmlMapper XML_MAPPER = new XmlMapper();

	@Override
	public byte[] objectTobytes(final Object obj) throws SerializeException {
		LOG.debug("Serialize object to xml on Jackson");
		try {
			return XML_MAPPER.writeValueAsBytes(obj);
		} catch (Exception e) {
			throw new SerializeException(e);
		}
	}

	@Override
	public <T> T bytesToObject(final byte[] bytes, final Class<? extends T> type) throws SerializeException {
		try {
			return XML_MAPPER.readValue(bytes, type);
		} catch (Exception e) {
			throw new SerializeException(e);
		}
	}

}
