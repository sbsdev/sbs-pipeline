package ch.sbs.pef;

import java.nio.charset.Charset;
import java.util.Collection;

import org.daisy.braille.table.AbstractConfigurableTableProvider;
import org.daisy.braille.table.BrailleConverter;
import org.daisy.braille.table.EmbosserBrailleConverter;
import org.daisy.braille.table.EmbosserBrailleConverter.EightDotFallbackMethod;
import org.daisy.braille.table.EmbosserTable;
import org.daisy.braille.table.Table;

import com.google.common.collect.ImmutableList;

public class SBSTableProvider extends AbstractConfigurableTableProvider<SBSTableProvider.TableType> {
	
	enum TableType { DE_CH_SBS };

	private final Collection<Table> tables;

	public SBSTableProvider() {
		super(EightDotFallbackMethod.values()[0], '\u2800');
		tables = new ImmutableList.Builder<Table>()
				.add(new EmbosserTable<TableType>("Pipeline", "", TableType.DE_CH_SBS, this))
				.build();
	}

	public BrailleConverter newTable(TableType type) {
		if (type != TableType.DE_CH_SBS)
			throw new IllegalArgumentException("Cannot find table type " + type);
		return new EmbosserBrailleConverter(
				new String(" A,B.K;L\"CIF\\MSP!E:H*O+R>DJG@NTQ'1?2-U(V$3960X^&<5/8)Z=[_4W7#Y]%"),
				Charset.forName("UTF-8"), fallback, replacement, false);
	}

	public Collection<Table> list() {
		return tables;
	}
}
